variable "db_password" {
  description = "Password for the PostgreSQL database."
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Username for the PostgreSQL database."
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "Database name for PostgreSQL."
  type        = string
  default     = "taskflowdb"
}

variable "db_storage" {
  description = "Storage size for PostgreSQL (Gi)."
  type        = string
  default     = "10Gi"
}
