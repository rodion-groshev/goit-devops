# Lesson 8–9: AWS Infra + EKS CI/CD (Terraform)

Provision an AWS VPC, ECR, EKS (with EBS CSI), RDS Postgres, and install **Jenkins** + **Argo CD**.  
CI builds/pushes Docker images to ECR; CD syncs Kubernetes manifests to EKS.

---

## What this creates

- **VPC**: public & private subnets, Internet Gateway, routing (DNS enabled; public subnets map public IPs)
- **ECR**: one repository for your app
- **EKS**: control plane + managed node group, OIDC, **EBS CSI add-on with IRSA**
- **RDS**: Postgres instance (dev defaults)
- **Jenkins**: installed via Helm into EKS (for CI)
- **Argo CD**: installed via Helm into EKS (for GitOps CD)

> Providers are wired to the EKS **module outputs** (endpoint + CA). No kubeconfig/localhost fallback.

---

## Prerequisites

- Terraform ≥ **1.5**
- **AWS CLI v2**, **kubectl**, **Helm 3**
- AWS credentials with permissions for VPC/EKS/ECR/RDS/IAM
- (Optional) GitHub Personal Access Token (PAT) if your repos are private
- (Optional) Docker (for local image testing; CI uses Kaniko in-cluster)

Verify tools:
```bash
aws sts get-caller-identity
terraform -version
kubectl version --client
helm version
```

---

## Configure

Create `terraform.tfvars` at the repo root with your values:

```hcl
region          = "eu-central-1"
cluster_name    = "lesson-8-9-eks"
repository_name = "lesson-8-9-ecr"

# Jenkins / ArgoCD (optional, for private repos)
github_username = "your-gh-user"
github_token    = "ghp_xxx..."         # store securely in CI, not in Git
github_repo_url = "https://github.com/your-org/your-app-configs.git"
```

Other useful variables are defined in the modules (instance type, scaling, tags, etc.).

---

## Deploy (two steps recommended)

```bash
terraform init -upgrade
```

**Step 1 — create/settle the cluster**
```bash
terraform apply -target=module.eks
```

Sanity checks:
```bash
aws eks update-kubeconfig --name lesson-8-9-eks --region eu-central-1
kubectl get nodes
kubectl -n kube-system get pods
kubectl get storageclass
```

**Step 2 — install the rest (Jenkins, Argo CD, RDS, etc.)**
```bash
terraform apply
```

Expected outputs include EKS endpoint/name, VPC subnet IDs, ECR repo URL, Jenkins & Argo CD namespaces.

---

## Access

### Kubernetes
```bash
aws eks update-kubeconfig --name lesson-8-9-eks --region eu-central-1
kubectl get nodes -o wide
kubectl get sc
```

### ECR (local login)
```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com
```

### RDS (dev-only public access)
Ensure security group allows your IP. Then:
```bash
psql "host=<rds-endpoint> port=5432 dbname=myapp user=postgres password=admin123AWS23 sslmode=require"
```

---

## Jenkins (CI)

Port-forward UI:
```bash
kubectl -n jenkins port-forward svc/jenkins 8081:8080
# open http://localhost:8081
```

Admin password:
```bash
kubectl -n jenkins get secret jenkins   -o jsonpath='{.data.jenkins-admin-password}' | base64 -d; echo
```

Example Pipeline (Kaniko → ECR):
```groovy
pipeline {
  agent any
  stages {
    stage('Build & Push') {
      steps {
        sh '''
        IMAGE="${ECR_REPO}:$GIT_COMMIT"
        echo "Building $IMAGE"
        /kaniko/executor           --context $WORKSPACE           --dockerfile Dockerfile           --destination $IMAGE
        '''
      }
    }
  }
  environment {
    ECR_REPO = "<ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/lesson-8-9-ecr"
  }
}
```

---

## Argo CD (CD)

Port-forward & login:
```bash
kubectl -n argocd port-forward svc/argo-cd-argocd-server 8080:443
# Open https://localhost:8080 (accept self-signed)

kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath='{.data.password}' | base64 -d; echo
# username: admin
```

Register repo & create app (CLI example):
```bash
argocd login localhost:8080 --username admin --password <pwd> --insecure

argocd repo add https://github.com/your-org/your-app-configs.git   --username $GITHUB_USER --password $GITHUB_TOKEN

argocd app create myapp   --repo https://github.com/your-org/your-app-configs.git   --path k8s/myapp   --dest-server https://kubernetes.default.svc   --dest-namespace default

argocd app sync myapp


```
> GitOps flow: update image tag in Git → Argo CD syncs to cluster.

# Prometheus and Grafana
## Get access to Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```
## Get access to Grafana
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```
#### Grafana credentials: admin / admin123 (або як в values.yaml)



---

## Day-2 Operations

### Scale nodes
- Via Terraform: update `desired_size`/`min_size`/`max_size` and `terraform apply`.
- Or via AWS Console/CLI on the managed node group.

### Upgrade EKS
- Bump `cluster_version` (module var), plan/apply.
- Upgrade/recreate node group to new AMI.
- EBS CSI add-on is pinned to a compatible version automatically.

### Destroy
```bash
terraform destroy
```
If IGW detach fails with `DependencyViolation: mapped public address(es)`, remove node groups, NAT GWs, and release EIPs first, then retry.

---

## Troubleshooting

**Kubernetes provider tries `http://localhost:80`**  
Providers are configured at root using EKS module outputs. Ensure no `provider "kubernetes"` or `provider "helm"` blocks exist inside submodules.

**`kubectl … no such host` for the EKS endpoint**  
Refresh kubeconfig and (if needed) set your DNS to public resolvers (1.1.1.1/8.8.8.8) then retry.

**Duplicate OIDC / `EntityAlreadyExists`**  
Keep a single `aws_iam_openid_connect_provider` in code. Import the existing ARN if AWS already has one.

**EBS CSI add-on `DEGRADED` or `Addon already exists`**  
The module has exactly one add-on resource; it waits for nodes and pins a compatible version. If you created one manually before, delete or import it.

**Node group `CREATE_FAILED: NodeCreationFailure`**  
Check:
- Public subnets have `map_public_ip_on_launch = true` (or place nodes in private subnets with NAT).
- VPC has `enable_dns_support = true` and `enable_dns_hostnames = true`.
- An **EKS Access Entry** exists for the node role (new EKS auth). If it already exists, import it into TF:
  ```bash
  terraform import 'module.eks.aws_eks_access_entry.nodes'     'lesson-8-9-eks,arn:aws:iam::<ACCOUNT_ID>:role/lesson-8-9-eks-eks-nodes'
  ```

**IGW detach `DependencyViolation`**  
Delete node groups (terminate instances), NAT gateways, and release any EIPs, then detach/delete the Internet Gateway.

---

## Security notes (dev vs prod)

- RDS is `publicly_accessible = true` for convenience; in prod set **false** and access via bastion/VPN.
- Restrict EKS `public_access_cidrs` to your IPs; avoid `0.0.0.0/0`.
- Prefer **private subnets** for nodes with NAT egress in production.

---

## Project structure

```
.
├── main.tf                 # orchestrates VPC, ECR, EKS, RDS, Jenkins, Argo CD
├── terraform.tfvars        # your values
├── modules/
│   ├── vpc/                # VPC + subnets (public subnets map public IPs)
│   ├── ecr/                # ECR repository and policy
│   ├── eks/                # EKS cluster, node group, OIDC/IRSA, EBS CSI
│   ├── rds/                # Postgres instance
│   ├── jenkins/            # Jenkins via Helm
│   └── argo_cd/            # Argo CD via Helm
└── README.md
```

---

## Notes for CI/CD integration

- **CI**: point Jenkins to the ECR repo (Terraform output). Build with Kaniko; no Docker daemon required.
- **CD**: store your Kubernetes manifests/Helm charts in a Git repo. Argo CD watches and syncs automatically.
- Use environment-specific overlays (e.g., Kustomize or Helm values) per environment.
