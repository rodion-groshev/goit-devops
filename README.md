# lesson-7 — EKS + ECR + Helm (Django)

## What this creates
- **EKS** cluster in your existing VPC (3 public + 3 private subnets), managed node group (2–6 nodes).
- **ECR** repository for your Django image.
- **Helm chart** for a Django app: Deployment, Service (LoadBalancer), HPA, ConfigMap.
- **Remote backend** via your existing S3 bucket + DynamoDB (reused from lesson-5).

## Prereqs
- Terraform >= 1.6; AWS CLI >= 2; kubectl; helm.
- AWS credentials configured (`aws sts get-caller-identity` works).
- Backend bucket/table: `goit-devops-lesson-5` / `terraform-locks` in `eu-central-1`.

## Bootstrap
1) Init backend and providers:
```bash
terraform init -reconfigure
```
2) Apply infra:
```bash
terraform plan
terraform apply
```
3) Configure kubectl:
```bash
aws eks update-kubeconfig --region eu-central-1 --name lesson-7-eks
kubectl get nodes
```

## Build & push your Django image to ECR
```bash
# Get the URL
REPO_URL=$(terraform output -raw ecr_repository_url)

# Authenticate Docker to ECR
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $(echo $REPO_URL | cut -d'/' -f1)

# Build and push (assuming your Dockerfile is at project root)
docker build -t lesson-7-django:latest .
docker tag lesson-7-django:latest ${REPO_URL}:latest
docker push ${REPO_URL}:latest
```

## Deploy with Helm
Edit `charts/django-app/values.yaml`:
- Set `image.repository` to `${REPO_URL}` (from above).
- Put your env vars under `env:` (moved from lesson 4).

Then:
```bash
helm upgrade --install django-app charts/django-app --namespace default
kubectl get svc django-app -o wide
```

## HPA requirement
HPA scales pods **2..6** when CPU > 70%. Metrics server required:
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Tear down
```bash
# App
helm uninstall django-app || true
# Infra
terraform destroy
```
