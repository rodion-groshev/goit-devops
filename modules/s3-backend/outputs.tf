locals {
  bucket_name_out = var.create ? aws_s3_bucket.tf_state[0].bucket : data.aws_s3_bucket.existing[0].bucket
  bucket_arn_out  = var.create ? aws_s3_bucket.tf_state[0].arn    : data.aws_s3_bucket.existing[0].arn
  table_name_out  = var.create ? aws_dynamodb_table.tf_locks[0].name : data.aws_dynamodb_table.existing[0].name
  table_arn_out   = var.create ? aws_dynamodb_table.tf_locks[0].arn  : data.aws_dynamodb_table.existing[0].arn
}
output "bucket_name" { value = local.bucket_name_out }
output "bucket_arn"  { value = local.bucket_arn_out }
output "dynamodb_table_name" { value = local.table_name_out }
output "dynamodb_table_arn"  { value = local.table_arn_out }
