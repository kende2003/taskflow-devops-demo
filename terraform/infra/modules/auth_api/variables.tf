variable "db_name" {
  description = "Database name for PostgreSQL."
  type        = string
}

variable "db_user" {
  description = "Username for the PostgreSQL database."
  type        = string
}

variable "db_password" {
  description = "Password for the PostgreSQL database."
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Host for the PostgreSQL database."
  type        = string

}

variable "auth_api_image_tag" {
  description = "ECR image tag for the auth-api service."
  type        = string
}
