# IAM role for EKS cluster
resource "aws_iam_role" "eks" {
  # Name of the IAM role for the EKS cluster
  name = "${var.cluster_name}-eks-cluster"

  # Policy that allows the EKS service to assume this IAM role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}
# Attach IAM role to AmazonEKSClusterPolicy
resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks.name
}

# Create the EKS cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = var.subnet_ids
  }
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  depends_on = [aws_iam_role_policy_attachment.eks]
}
