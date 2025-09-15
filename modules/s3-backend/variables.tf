variable "bucket_name" {
  type = string
}
variable "table_name"  {
  type    = string
  default = "terraform-locks"
}
variable "create" {
  type    = bool
  default = true
}
