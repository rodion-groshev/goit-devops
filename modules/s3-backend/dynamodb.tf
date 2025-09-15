data "aws_dynamodb_table" "existing" {
  count = var.create ? 0 : 1
  name  = var.table_name
}

resource "aws_dynamodb_table" "tf_locks" {
  count        = var.create ? 1 : 0
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = var.table_name
    ManagedBy = "Terraform"
    Purpose   = "TerraformLocks"
  }
}
