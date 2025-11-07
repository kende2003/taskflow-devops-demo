output "postgresql_service_name" {
  description = "The name of the PostgreSQL headless service."
  value       = kubernetes_service.postgresql_headless.metadata[0].name
}

output "postgresql_service_host" {
  description = "The DNS host for PostgreSQL pods."
  value       = "${kubernetes_service.postgresql_headless.metadata[0].name}.${kubernetes_service.postgresql_headless.metadata[0].namespace}.svc.cluster.local"
}

output "postgresql_namespace" {
  description = "Namespace where PostgreSQL is deployed."
  value       = kubernetes_namespace.postgresql_db.metadata[0].name
}
