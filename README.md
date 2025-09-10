# lesson-5 — Terraform on AWS (S3+DynamoDB backend, VPC, ECR)

## Project structure
```text
lesson-5/
├── main.tf
├── backend.tf
├── outputs.tf
├── modules/
│   ├── s3-backend/
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpc/
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ecr/
│       ├── ecr.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md
```

## What this creates
- **Remote state backend**: S3 bucket (versioned, encrypted, public access blocked) + DynamoDB table for state locking.
- **Networking**: 1 VPC, 3 public subnets, 3 private subnets across three AZs, 1 Internet Gateway, 3 NAT Gateways (one per AZ), route tables and associations.
- **Container registry**: 1 ECR repository with image scan on push and a basic repository policy.

> **Cost note**: NAT Gateways are billed hourly + data. Three NATs are used (best practice per AZ). For labs, you can reduce to one NAT Gateway to save money.

## Prerequisites
- Terraform >= 1.6
- AWS credentials configured (e.g., via `aws configure` or environment variables).
- Pick a **globally unique** S3 bucket name for the backend.


## Usage
```bash
terraform init
terraform plan
terraform apply
# ...later
terraform destroy
```

### Notes on destroy
- The S3 state bucket is meant to be **kept**. If you try to destroy everything, Terraform will fail because the bucket contains the state file. Either keep it, or (not recommended) empty and remove it manually.

## Module overview
- **modules/s3-backend**: S3 bucket (versioning, encryption, public access block) + DynamoDB table (on-demand) for state locking.
- **modules/vpc**: VPC with 3 public and 3 private subnets across supplied AZs, 1 Internet Gateway, 3 NAT Gateways, and per-subnet routing.
- **modules/ecr**: Private ECR repository with scan-on-push and a policy allowing your account to push/pull.
