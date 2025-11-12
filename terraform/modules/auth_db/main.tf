data "aws_caller_identity" "current" {}

resource "kubernetes_namespace" "postgresql_db" {
  metadata {
    name = "postgresql-db"
  }

}

resource "kubernetes_secret" "postgres_password" {
  metadata {
    name = "postgres-secret"
    namespace = kubernetes_namespace.postgresql_db.metadata[0].name
  }

  data = {
    POSTGRES_PASSWORD = base64encode(var.db_password)
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "db_config" {
  metadata {
    name      = "db-config"
    namespace = kubernetes_namespace.postgresql_db.metadata[0].name
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
        Sid = "AllowKendiFullManagement",
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
        Sid = "AllowAdminFullManagement",
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
        Sid = "AllowEksClusterUseKey",
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

resource "kubernetes_stateful_set" "auth_db" {
  metadata {
    name      = "users-db"
    namespace = kubernetes_namespace.postgresql_db.metadata[0].name
    labels = {
      app = "users-db"
    }
  }

  spec {
    service_name = kubernetes_service.postgresql_headless.metadata[0].name
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
          image = "postgres:16"

          env {
            name  = "POSTGRES_USER"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.db_config.metadata[0].name
                key  = "DB_USER"
              }
            }
          }
          env {
            name  = "POSTGRES_DB"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.db_config.metadata[0].name
                key  = "DB_NAME"
              }
            }
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_password.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          port {
            container_port = 5432
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
        storage_class_name = kubernetes_storage_class.db_storage_class.metadata[0].name
      }
    }
  }
}


resource "kubernetes_service" "postgresql_headless" {
  metadata {
    name      = "postgresql-svc"
    namespace = "postgresql-db"
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
      protocol = "TCP"
    }
    cluster_ip = "None"
  }
}




resource "kubernetes_storage_class" "db_storage_class" {
    metadata {
        name = "encrypted-ebs-sc"
    }

    storage_provisioner = "ebs.csi.aws.com"

    parameters = {
      type = "gp3"
      fsType = "ext4"
      encrypted = "true"
      kmsKeyId = aws_kms_key.ebs_encryption.arn
    }

    reclaim_policy = "Retain"
    volume_binding_mode = "WaitForFirstConsumer"
    allow_volume_expansion = true

}



