# DevOps Infrastructure on AWS EKS

This project provisions a complete Kubernetes environment on AWS using Terraform. 
It sets up networking, EKS cluster, CI/CD tools, and supporting components.

## Components

- **VPC Module** — Creates networking (VPC, subnets, security groups, routes).
- **EKS Module** — Provisions the Amazon Elastic Kubernetes Service (EKS) cluster and node groups.
- **ECR Module** — Creates Elastic Container Registry for storing Docker images.
- **Argo CD Module** — Deploys Argo CD via Helm for GitOps-based application delivery.
- **Jenkins Module** — Installs Jenkins with persistent storage and service exposure.
- **EBS CSI Driver** — Provides dynamic volume provisioning using Amazon EBS.

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with credentials and region
- kubectl installed and configured
- helm installed (optional for direct Helm testing)

## Deployment

1. Initialize Terraform:
   ```bash
   terraform init -reconfigure -upgrade
   ```

2. Plan the changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Access

- **Argo CD UI**
  - Service: `argo-cd-argocd-server` in namespace `argocd`
  - Default user: `admin`
  - Password: stored in secret `argocd-initial-admin-secret`

- **Jenkins UI**
  - Service: `jenkins` in namespace `jenkins`
  - Admin password: stored in the Jenkins secret (check via `kubectl get secret -n jenkins`)

## Destroy

To tear down all resources:
```bash
terraform destroy
```

## Troubleshooting

- If Terraform reports `ResourceInUseException` or `AlreadyExists`, import the existing resource:
  ```bash
  terraform import <address> <id>
  ```

- If Helm fails with "name already in use", either import the release or uninstall it manually:
  ```bash
  helm -n <namespace> uninstall <release>
  ```

- To check cluster health:
  ```bash
  kubectl get nodes
  kubectl get pods -A
  ```

---

**Note:** Be careful when running `terraform destroy` — it will delete the EKS cluster and all workloads.
