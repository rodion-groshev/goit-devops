output "ecr_repository_url" { value = module.ecr.repository_url }

output "eks" {
  value = {
    cluster_name = module.eks.cluster_name
    cluster_arn  = module.eks.cluster_arn
    endpoint     = module.eks.cluster_endpoint
    oidc_issuer  = module.eks.cluster_oidc_issuer
  }
}

output "kubectl_update_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
