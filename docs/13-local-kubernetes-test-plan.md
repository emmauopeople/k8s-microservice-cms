# Local Kubernetes Test Plan

This plan tests the church application manifests on the local Docker/WSL Kubernetes cluster before paying for AWS EKS runtime.

The local test validates Kubernetes behavior, service wiring, ECR image pull, OVH PostgreSQL connectivity, health checks, and metrics endpoints.

## What this test covers

- Kubernetes namespace creation
- ECR image pull secret
- Deployment manifests
- Service discovery
- Environment variables
- Kubernetes Secrets
- Backend connection to OVH PostgreSQL through `DATABASE_URL`
- `/health`
- `/health/db`
- `/metrics`
- Frontend container health endpoint

## What this test does not cover

- AWS Load Balancer Controller
- AWS ALB Ingress behavior
- ACM certificate validation
- Route 53 DNS records
- WAF association
- IRSA behavior against AWS services
- EKS node IAM behavior

Those are validated later in AWS EKS.

## Required local tools

- kubectl
- helm
- aws cli
- working access to the local Kubernetes cluster
- AWS CLI configured with access to ECR
- OVH PostgreSQL `DATABASE_URL` values

Check AWS identity:

```bash
aws sts get-caller-identity
```

Check Kubernetes context:

```bash
kubectl config current-context
kubectl get nodes
```

## Pull latest platform repo

```bash
cd ~/k8s-microservice-cms

git fetch origin
git checkout feature/platform-foundation
git pull origin feature/platform-foundation
```

## Create ECR pull secret

```bash
chmod +x scripts/local-test/*.sh
./scripts/local-test/create-ecr-pull-secret.sh
```

This creates:

```text
ecr-registry-secret
```

in:

```text
church-prod
```

The ECR token expires, so recreate this secret if image pulls fail later.

## Create app secrets

Do not commit real `DATABASE_URL` values.

Set the values only in the terminal session:

```bash
export AUTH_DATABASE_URL='postgresql://AUTH_USER:AUTH_PASSWORD@OVH_HOST:5432/auth_db'
export CHURCH_CORE_DATABASE_URL='postgresql://CORE_USER:CORE_PASSWORD@OVH_HOST:5432/church_core_db'
export DOCUMENT_DATABASE_URL='postgresql://DOCUMENT_USER:DOCUMENT_PASSWORD@OVH_HOST:5432/document_core_db'
export JWT_SECRET_VALUE='change-this-secret-before-production'
```

Then create Kubernetes Secrets:

```bash
./scripts/local-test/create-church-app-secrets.sh
```

This creates:

```text
auth-service-db
church-core-service-db
document-service-db
auth-service-secret
church-core-service-secret
document-service-secret
```

## Find the image tag to test

Use an ECR image tag already pushed by the app repo workflow.

Example:

```bash
aws ecr describe-images \
  --region us-east-1 \
  --repository-name church-auth-service \
  --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags' \
  --output table
```

The tag should look like:

```text
prod-abc1234
```

Use the same tag for all services if the workflow built all services from the same commit.

## Deploy locally

```bash
export IMAGE_TAG='prod-abc1234'
./scripts/local-test/deploy-church-app-local.sh
```

The script installs the Helm chart using:

```text
helm/apps/church-app/values-local-cka.yaml
```

It deploys one replica per service and disables Ingress for the first test.

## Smoke test

```bash
./scripts/local-test/test-church-app-local.sh
```

Expected checks:

```text
frontend /health
auth-service /health
auth-service /health/db
auth-service /metrics
church-core-service /health
church-core-service /health/db
church-core-service /metrics
document-service /health
document-service /health/db
document-service /metrics
```

## Port-forward frontend and APIs

Use these commands if the frontend image expects localhost API URLs:

```bash
kubectl -n church-prod port-forward svc/frontend 8080:8080
kubectl -n church-prod port-forward svc/auth-service 4001:4001
kubectl -n church-prod port-forward svc/church-core-service 4002:4002
kubectl -n church-prod port-forward svc/document-service 4003:4003
```

Open:

```text
http://localhost:8080
```

## Important frontend note

The frontend is a Vite static build. Its API URLs are build-time values, not runtime container environment variables.

For AWS EKS production, the app repo CI/CD must build the frontend with:

```text
VITE_AUTH_API_URL=https://api.eks.gestionparoissiale.org
VITE_CHURCH_CORE_API_URL=https://api.eks.gestionparoissiale.org
VITE_DOCUMENT_API_URL=https://api.eks.gestionparoissiale.org
```

If the current ECR frontend image was built without these args, it may still call localhost URLs. That is acceptable for the first local test using port-forwarding, but it must be fixed before AWS EKS deployment.

## Troubleshooting

Check image pull:

```bash
kubectl -n church-prod describe pod <pod-name>
```

Check logs:

```bash
kubectl -n church-prod logs deploy/auth-service
kubectl -n church-prod logs deploy/church-core-service
kubectl -n church-prod logs deploy/document-service
kubectl -n church-prod logs deploy/frontend
```

Check service DNS from inside the cluster:

```bash
kubectl -n church-prod run dns-test --rm -i --restart=Never --image=busybox:1.36 -- nslookup church-core-service
```

Check DB connectivity errors:

```bash
kubectl -n church-prod logs deploy/auth-service | tail -100
kubectl -n church-prod logs deploy/church-core-service | tail -100
kubectl -n church-prod logs deploy/document-service | tail -100
```

## Cleanup local test

```bash
helm -n church-prod uninstall church-app
kubectl delete namespace church-prod
```
