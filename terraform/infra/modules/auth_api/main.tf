
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
    DB_HOST = var.db_host
    DB_USER = var.db_user
    DB_NAME = var.db_name
  }
}

resource "kubernetes_deployment" "auth_api" {
  metadata {
    name      = "auth-api"
    namespace = kubernetes_namespace.auth_api.metadata[0].name
    labels = {
      app = "auth-api"
    }
  }

  wait_for_rollout = true

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
          image = "536284936715.dkr.ecr.eu-central-1.amazonaws.com/auth-api:${var.auth_api_image_tag}"
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
            value = var.db_password
          }
        }
      }
    }
  }
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
