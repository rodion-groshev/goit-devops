variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  type        = string
  description = "IMMUTABLE or MUTABLE"
  default     = "MUTABLE"
}

variable "force_delete" {
  type        = bool
  description = "If true, deleting the repo also deletes all images inside."
  default     = true
}

variable "repository_policy" {
  type        = string
  description = "JSON policy for the repository."
  default     = null
}
