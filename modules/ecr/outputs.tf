output "repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.ecr.arn
}

output "registry_id" {
  description = "Registry ID of the ECR"
  value       = aws_ecr_repository.ecr.registry_id
}
