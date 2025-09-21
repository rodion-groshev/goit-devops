variable "kubeconfig" {
  description = "Path to kubeconfig file"
  type        = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "IRSA ARN OIDC"
  type        = string
}

variable "oidc_provider_url" {
  description = "IRSA URL OIDC"
  type        = string
}

variable "github_username" {
  description = "GitHub username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}
