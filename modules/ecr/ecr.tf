resource "aws_ecr_repository" "this" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
  tags = { Name = var.ecr_name, ManagedBy = "Terraform" }
}
