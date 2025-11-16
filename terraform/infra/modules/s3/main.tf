/*resource "aws_s3_bucket" "tf_state" {
  bucket = "my-tf-state-bucket"

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = aws_s3_bucket.tf_state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse_config" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "tf-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}*/