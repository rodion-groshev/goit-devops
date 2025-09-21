variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "lesson-8-9-eks"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster and node group"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "node-group"
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.small"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

# Optional hardening / ergonomics

variable "cluster_version" {
  description = "EKS Kubernetes version (major.minor)"
  type        = string
  default     = "1.33"
}

variable "public_access_cidrs" {
  description = "Allowed CIDRs for public EKS endpoint (empty => provider default)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to EKS resources"
  type        = map(string)
  default     = {}
}
