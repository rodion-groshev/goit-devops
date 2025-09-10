variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ)"
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR blocks for private subnets (one per AZ)"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones to spread subnets across"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
  default     = "lesson-5-vpc"
}
