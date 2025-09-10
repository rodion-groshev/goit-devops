variable "bucket_name" {
  description = "Globally unique S3 bucket name to store Terraform state"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-locks"
}
