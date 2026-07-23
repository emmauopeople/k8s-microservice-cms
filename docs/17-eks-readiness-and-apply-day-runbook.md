# EKS Readiness and Apply-Day Runbook

This runbook captures the remaining steps needed to move from the proven local Kubernetes setup to the AWS EKS demo environment.

No Terraform apply is required while preparing this document and the supporting scripts. Execute the apply steps only on the planned AWS demo day.

## Current local validation status

The local platform validation has already proven:

- Container images build and push to Amazon ECR.
- GitHub Actions can update the GitOps image tag file.
- Argo CD can reconcile the Helm app into Kubernetes.
- Prometheus and Grafana can scrape and visualize service metrics.
- Fluent Bit and OpenSearch can centralize and search Kubernetes logs.

## Pre-apply repository alignment

Before running Terraform for EKS:

1. Merge `k8s-microservice-cms` branch `feature/platform-foundation` into `main`.
2. Merge `church_app` branch `feature` into `main` so the production workflow includes:
   - frontend API build profile support,
   - ECR build/push,
   - GitOps image tag update,
   - platform repo update through `PLATFORM_REPO_TOKEN`.
3. Confirm `helm/apps/church-app/values-image-tags.yaml` has the latest `prod-<short-sha>` tag.
4. Confirm the production Argo CD app points to the correct platform branch. For final demo, use `main`.

## Pre-apply local checks

From the platform repo:

```bash
cd infra/envs/prod-demo
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

Do not run `terraform apply` until the planned AWS demo window.

## Security change before apply

Restrict the EKS public API endpoint to your current public IP.

Current variable:

```hcl
eks_public_access_cidrs = ["0.0.0.0/0"]
```

Set it to your IP `/32` before apply:

```hcl
eks_public_access_cidrs = ["<your-public-ip>/32"]
```

## Terraform apply sequence

### 1. First apply

Run the first apply to create:

- VPC and subnets,
- NAT Gateway,
- ECR repositories,
- EKS cluster and node group,
- RDS PostgreSQL,
- S3 document bucket,
- Route 53 hosted zone,
- ACM certificate request,
- WAF,
- IRSA roles,
- Velero bucket,
- EBS CSI addon.

```bash
cd infra/envs/prod-demo
terraform apply
```

### 2. Capture outputs

```bash
terraform output dns_name_servers
terraform output acm_certificate_arn
terraform output waf_web_acl_arn
terraform output irsa_document_service_s3_role_arn
terraform output velero_backup_bucket_name
terraform output rds_endpoint
```

### 3. Delegate DNS in Namecheap

Delegate only this subdomain:

```text
eks.gestionparoissiale.org
```

to the Route 53 name servers returned by Terraform.

Do not move the root domain or `www.gestionparoissiale.org`; those remain on the current OVH/Docker Swarm deployment.

### 4. Enable ACM validation

After Namecheap delegation propagates, set:

```hcl
enable_acm_certificate_validation = true
```

Then run:

```bash
terraform apply
```

Confirm ACM status becomes issued.

## Configure kubectl

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name church-prod-demo-eks

kubectl get nodes
```

## Install Argo CD

```bash
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server
```

## Create required operational secrets

### Grafana admin secret

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

kubectl -n monitoring create secret generic grafana-admin-credentials \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='<strong-grafana-password>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

### Church app database/JWT secrets

Follow:

```text
docs/16-ovh-to-rds-database-backup-restore-runbook.md
```

Use:

```bash
scripts/rds/bootstrap-rds-app-databases.sh
scripts/restore/restore-postgres-databases-to-rds.sh
scripts/eks/create-church-app-secrets-from-rds.sh
```

## GitOps sync order

Apply/sync Argo CD applications in this order:

1. `storageclass-gp3`
2. `monitoring`
3. `opensearch`
4. `opensearch-dashboards`
5. `fluent-bit`
6. `velero`
7. `church-app`

The `storageclass-gp3` application should be synced after the EBS CSI addon exists and before monitoring/OpenSearch because those components use `gp3` PVCs.

```bash
kubectl apply -f gitops/addons/storageclass-gp3.yaml
kubectl apply -f gitops/addons/monitoring.yaml
kubectl apply -f gitops/addons/opensearch.yaml
kubectl apply -f gitops/addons/opensearch-dashboards.yaml
kubectl apply -f gitops/addons/fluent-bit.yaml
kubectl apply -f gitops/addons/velero.yaml
kubectl apply -f gitops/apps/church-app.yaml
```

## Helm value updates after Terraform outputs

Before syncing `church-app`, update Helm values or overlays with these Terraform outputs:

| Helm value | Terraform output |
|---|---|
| `ingress.certificateArn` | `acm_certificate_arn` |
| `ingress.wafAclArn` | `waf_web_acl_arn` |
| `serviceAccounts.document-service.annotations.eks.amazonaws.com/role-arn` | `irsa_document_service_s3_role_arn` |

The current app still stores documents in PostgreSQL, but the S3 IRSA role is ready for the future S3 document-storage enhancement.

## App CI/CD deployment flow

After EKS and Argo CD are ready:

1. Push or merge app code to `church_app/main`.
2. GitHub Actions builds images and pushes them to ECR.
3. The workflow updates `helm/apps/church-app/values-image-tags.yaml` in the platform repo.
4. Argo CD detects the Git change.
5. Argo CD rolls out the updated workloads to EKS.

## Validation checklist

```bash
kubectl get nodes
kubectl get ns
kubectl -n argocd get applications
kubectl -n church-prod get deploy,pods,svc,ingress
kubectl -n monitoring get pods,pvc
kubectl -n logging get pods,pvc
kubectl -n velero get pods
```

Application health:

```bash
kubectl -n church-prod rollout status deploy/frontend
kubectl -n church-prod rollout status deploy/auth-service
kubectl -n church-prod rollout status deploy/church-core-service
kubectl -n church-prod rollout status deploy/document-service
```

Browser checks:

```text
https://eks.gestionparoissiale.org
https://api.eks.gestionparoissiale.org/auth/health
https://api.eks.gestionparoissiale.org/core/health
https://api.eks.gestionparoissiale.org/documents/health
```

Observability checks:

- Prometheus targets show backend services UP.
- Grafana dashboard shows app metrics.
- OpenSearch has `kubernetes-*` indices.
- OpenSearch Discover can filter `kubernetes.namespace_name:"church-prod"`.

## Pre-destroy checklist

Before destroying the environment:

1. Capture screenshots for portfolio evidence.
2. Export Grafana dashboard screenshots.
3. Export OpenSearch log screenshots.
4. Verify RDS snapshot/backups if needed.
5. Run backup check:

```bash
scripts/backup/pre-destroy-backup-check.sh
```

6. Confirm no important files exist only in the EKS/RDS demo environment.

Then destroy:

```bash
cd infra/envs/prod-demo
terraform destroy
```
