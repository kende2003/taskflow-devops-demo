variable "region" {
  description = "Region for the provider"
  type        = string
  default     = "eu-central-1"
}

variable "profile" {
  description = "Profile for the region, likely the profile will assume a role"
  type        = string
}

variable "project_name" {
  description = "This value will be used as a tag for the related AWS resources!"
  type        = string
}

variable "db_password" {
  description = "Value for the database password"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Value for the database user"
  type        = string
  default     = "taskflowdb"  
}

variable "db_storage" {
  description = "Value for the database storage size"
  type        = string
  default     = "20Gi"
  
}