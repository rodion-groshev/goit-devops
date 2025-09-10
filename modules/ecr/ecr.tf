data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "this" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = var.scan_on_push }
  encryption_configuration { encryption_type = "AES256" }
  tags = { Name = var.ecr_name, ManagedBy = "Terraform" }
}

data "aws_iam_policy_document" "repo_policy" {
  statement {
    sid    = "AllowAccountPushPull"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage"
      # optional, usually fine too:
      # "ecr:ListImages"
    ]
  }
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.repo_policy.json
}
