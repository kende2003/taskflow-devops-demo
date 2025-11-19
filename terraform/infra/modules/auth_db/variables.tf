variable "db_password" {
  description = "Password for the PostgreSQL database."
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Username for the PostgreSQL database."
  type        = string
}

variable "db_name" {
  description = "Database name for PostgreSQL."
  type        = string
}

variable "db_storage" {
  description = "Storage size for PostgreSQL (Gi)."
  type        = string
}

variable "aws_iam_user" {
  description = "AWS IAM user for database encryption key access on EBS."
  type        = string
}

variable "eks_node_role_arn" {
  description = "EKS Node Role ARN for granting access to KMS key."
  type        = string 
}
