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

variable "aws_iam_user" {
  description = "AWS IAM user."
  type        = string

}
