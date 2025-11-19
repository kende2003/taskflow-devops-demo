resource "aws_ecr_repository" "auth_api_repo" {
  name                 = "auth-api"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "auth-api"
  }
}