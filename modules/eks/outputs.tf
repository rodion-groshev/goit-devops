output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.eks.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.eks.arn
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks.name
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = aws_eks_cluster.eks.version
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_certificate_authority_data" {
  description = "PEM-encoded cluster CA"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "node_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  value       = aws_iam_role.nodes.arn
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "IAM OIDC provider URL"
  value       = aws_iam_openid_connect_provider.this.url
}
