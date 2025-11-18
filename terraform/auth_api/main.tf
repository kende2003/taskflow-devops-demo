data "terraform_remote_state" "auth_db" {
  backend = "s3"
  config = {
    bucket = "taskflow-tf-state-bucket"
    key    = "auth_db/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  db_host = data.terraform_remote_state.auth_db.outputs.db_host
  db_name = data.terraform_remote_state.auth_db.outputs.db_name
  db_user = data.terraform_remote_state.auth_db.outputs.db_user
  db_password = data.terraform_remote_state.auth_db.outputs.db_password
}


resource "kubernetes_namespace" "auth_api" {
  metadata {
    name = "auth-api"
  }
}

resource "kubernetes_config_map" "auth_config" {
  metadata {
    name      = "auth-config"
    namespace = kubernetes_namespace.auth_api.metadata[0].name
  }

  data = {
    DB_HOST = local.db_host
    DB_USER = local.db_user
    DB_NAME = local.db_name
  }
}

resource "kubernetes_secret" "auth_api_db_secret" {
  metadata {
    name      = "auth-api-db-secret"
    namespace = kubernetes_namespace.auth_api.metadata[0].name
  }

  data = {
    POSTGRES_PASSWORD = local.db_password
  }
  type = "Opaque"
}


resource "kubernetes_deployment" "auth_api" {
  metadata {
    name      = "auth-api"
    namespace = kubernetes_namespace.auth_api.metadata[0].name
    labels = {
      app = "auth-api"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "auth-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "auth-api"
        }
      }

      spec {
        container {
          name  = "auth-api"
          image = "536284936715.dkr.ecr.eu-central-1.amazonaws.com/auth-api:latest"
          port {
            container_port = 8080
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.auth_config.metadata[0].name
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth_api_db_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_config_map.auth_config,
    kubernetes_secret.auth_api_db_secret
  ]
}


resource "kubernetes_service" "auth_api_service" {
  metadata {
    name      = "auth-api-service"
    namespace = kubernetes_namespace.auth_api.metadata[0].name
  }

  spec {
    selector = {
      app = "auth-api"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}
