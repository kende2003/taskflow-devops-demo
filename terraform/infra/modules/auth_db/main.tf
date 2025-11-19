data "aws_caller_identity" "current" {}

resource "kubernetes_namespace" "auth_db" {
  metadata {
    name = "auth-db"
  }

}

resource "kubernetes_secret" "auth_db_password" {
  metadata {
    name      = "auth-db-secret"
    namespace = kubernetes_namespace.auth_db.metadata[0].name
  }

  data = {
    POSTGRES_PASSWORD = var.db_password
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "db_config" {
  metadata {
    name      = "auth-db-config"
    namespace = kubernetes_namespace.auth_db.metadata[0].name
  }

  data = {
    DB_NAME = var.db_name
    DB_USER = var.db_user
  }

}

resource "aws_kms_key" "ebs_encryption" {
  description             = "KMS key for EBS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Sid    = "AllowIAMUserFullManagement",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.aws_iam_user}"
        },
        Action = [
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowAdminFullManagement",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowEKSClusterUseKey",
        Effect = "Allow",
        Principal = {
          AWS = var.eks_node_role_arn
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })

}

resource "aws_kms_alias" "eks" {
  name          = "alias/ebs-key"
  target_key_id = aws_kms_key.ebs_encryption.id
}

resource "kubernetes_stateful_set" "users_db" {
  metadata {
    name      = "users-db"
    namespace = kubernetes_namespace.auth_db.metadata[0].name
    labels = {
      app = "users-db"
    }
  }

  wait_for_rollout            = true
  
  spec {
    service_name = kubernetes_service.auth_db_headless_service.metadata[0].name
    replicas     = 1

    selector {
      match_labels = {
        app = "users-db"
      }
    }

    template {
      metadata {
        labels = {
          app = "users-db"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:16-alpine"

          env {
            name = "POSTGRES_USER"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.db_config.metadata[0].name
                key  = "DB_USER"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.db_config.metadata[0].name
                key  = "DB_NAME"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth_db_password.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }
          port {
            container_port = 5432
          }
           readiness_probe {
            tcp_socket {
              port = 5432
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 6
          }
          volume_mount {
            name       = "pgdata"
            mount_path = "/var/lib/postgresql/data"
          }
        }
        
      }
    }

    volume_claim_template {
      metadata {
        name = "pgdata"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.db_storage
          }
        }
        storage_class_name = kubernetes_storage_class.auth_db_storage_class.metadata[0].name
      }
    }
  }
}


resource "kubernetes_service" "auth_db_headless_service" {
  metadata {
    name      = "auth-db-svc"
    namespace = kubernetes_namespace.auth_db.metadata[0].name
    labels = {
      app = "users-db"
    }
  }
  spec {
    selector = {
      app = "users-db"
    }
    port {
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_storage_class" "auth_db_storage_class" {
  metadata {
    name = "encrypted-ebs-sc"
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type      = "gp3"
    fsType    = "ext4"
    encrypted = "true"
    iops      = "5000"
    kmsKeyId  = aws_kms_key.ebs_encryption.arn
  }

  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}



