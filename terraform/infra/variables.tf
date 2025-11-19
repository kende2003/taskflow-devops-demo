variable "region" {
  description = "Region for the provider"
  type        = string
  default     = "eu-central-1"
}

variable "profile" {
  description = "Profile for the region, likely the profile will assume a role"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "This value will be used as a tag for the related AWS resources!"
  type        = string
  default     = "taskflow-demo"
}

variable "auth_db_user" {
  description = "Username for the PostgreSQL database."
  type        = string
  default     = "postgres"
}

variable "auth_db_password" {
  description = "Password for the PostgreSQL database."
  type        = string
  sensitive   = true

}

variable "auth_db_name" {
  description = "Database name for PostgreSQL."
  type        = string
  default     = "usersdb"

}

variable "auth_db_storage" {
  description = "Storage size for PostgreSQL (Gi)."
  type        = string
  default     = "20Gi"

}

variable "aws_iam_user" {
  description = "AWS IAM user."
  type        = string
}
