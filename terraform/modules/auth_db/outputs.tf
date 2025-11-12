output "postgresql_service_name" {
  description = "The name of the PostgreSQL headless service."
  value       = kubernetes_service.postgresql_headless.metadata[0].name
}

output "db_name" {
  description = "PostgreSQL database name"
  value       = var.db_name
}

output "db_user" {
  description = "PostgreSQL database username"
  value       = var.db_user
}

output "db_password" {
  description = "PostgreSQL database password"
  value       = var.db_password
  sensitive   = true
}

output "db_host" {
  description = "The DNS host for PostgreSQL pods."
  value       = "${kubernetes_service.postgresql_headless.metadata[0].name}.${kubernetes_service.postgresql_headless.metadata[0].namespace}.svc.cluster.local"
}

output "postgresql_namespace" {
  description = "Namespace where PostgreSQL is deployed."
  value       = kubernetes_namespace.postgresql_db.metadata[0].name
}
