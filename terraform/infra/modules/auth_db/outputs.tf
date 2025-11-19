output "auth_db_service_name" {
  description = "The name of the PostgreSQL headless service."
  value       = kubernetes_service.auth_db_headless_service.metadata[0].name
}

output "auth_db_name" {
  description = "PostgreSQL database name"
  value       = var.db_name
}

output "auth_db_user" {
  description = "PostgreSQL database username"
  value       = var.db_user
}

output "auth_db_password" {
  description = "PostgreSQL database password"
  value       = var.db_password
  sensitive   = true
}

output "auth_db_host" {
  description = "The DNS host for PostgreSQL pods."
  value       = "${kubernetes_service.auth_db_headless_service.metadata[0].name}.${kubernetes_service.auth_db_headless_service.metadata[0].namespace}.svc.cluster.local"
}

output "auth_db_namespace" {
  description = "Namespace where PostgreSQL is deployed."
  value       = kubernetes_namespace.auth_db.metadata[0].name
}

output "auth_db_secret_name" {
  description = "Kubernetes secret name for the PostgreSQL database password."
  value = kubernetes_secret.auth_db_password.metadata[0].name
}