terraform {
  backend "s3" {
    bucket         = "taskflow-tf-state-bucket"
    key            = "auth_db/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "taskflow-tf-lock-table"
  }
}
