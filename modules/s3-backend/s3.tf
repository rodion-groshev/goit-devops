data "aws_s3_bucket" "existing" {
  count  = var.create ? 0 : 1
  bucket = var.bucket_name
}

resource "aws_s3_bucket" "tf_state" {
  count         = var.create ? 1 : 0
  bucket        = var.bucket_name
  force_destroy = false
  tags = {
    Name      = var.bucket_name
    ManagedBy = "Terraform"
    Purpose   = "TerraformState"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.tf_state[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  count                   = var.create ? 1 : 0
  bucket                  = aws_s3_bucket.tf_state[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
