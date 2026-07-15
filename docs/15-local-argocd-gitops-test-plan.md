# Local Argo CD GitOps Test Plan

This test proves that the church application can be deployed through GitOps before moving the same pattern to AWS EKS.

## Goal

Move from manual Helm deployment to Argo CD-managed deployment:

```text
GitHub platform repo -> Argo CD -> Helm chart -> local Kubernetes cluster -> church-prod namespace
```

This is a portfolio-relevant step because production Kubernetes platforms usually avoid manual `helm upgrade` from a laptop and instead let a GitOps controller continuously reconcile the cluster from Git.

## Prerequisites

The following should already exist from the local Kubernetes test:

- Local Kubernetes cluster is running.
- ECR pull secret exists in `church-prod`.
- App database/JWT secrets exist in `church-prod`.
- App images have already been pushed to ECR.
- `IMAGE_TAG` is known, for example `prod-abc1234`.

Check secrets:

```bash
kubectl get secret -n church-prod ecr-registry-secret church-app-secrets
```

## 1. Install Argo CD Locally

```bash
./scripts/local-test/install-argocd-local.sh
```

This installs Argo CD into the `argocd` namespace and prints the initial admin password.

## 2. Open the Argo CD UI

In a separate terminal:

```bash
./scripts/local-test/port-forward-argocd-local.sh
```

Open:

```text
https://localhost:8081
```

Login:

```text
Username: admin
Password: value printed by install-argocd-local.sh
```

The browser may show a certificate warning because this is local testing with a self-signed certificate.

## 3. Apply the Church App Application

Use the same image tag that was already tested locally:

```bash
export IMAGE_TAG='prod-abc1234'
./scripts/local-test/apply-argocd-church-app-local.sh
```

This creates an Argo CD Application named:

```text
church-app-local
```

The local Application points to:

```text
repo: https://github.com/emmauopeople/k8s-microservice-cms.git
branch: feature/platform-foundation
path: helm/apps/church-app
values file: values-local-cka.yaml
```

## 4. Validate Argo CD Sync

```bash
./scripts/local-test/test-argocd-local.sh
```

Expected result:

```text
sync=Synced health=Healthy
```

Also verify the app workloads:

```bash
kubectl get deploy,pods,svc -n church-prod
```

## 5. Validate the Application Still Works

Run the existing application test:

```bash
./scripts/local-test/test-church-app-local.sh
```

You can also port-forward the frontend:

```bash
kubectl -n church-prod port-forward svc/frontend 8088:8080
```

Then open:

```text
http://localhost:8088
```

## Screenshots to Capture

Capture these for the portfolio:

1. Argo CD UI showing `church-app-local`.
2. Argo CD app status: `Synced` and `Healthy`.
3. Argo CD resource tree showing Deployments, Services, ConfigMaps, and ServiceAccounts.
4. Terminal output from `test-argocd-local.sh`.
5. Church app browser working after Argo CD reconciliation.

## Important Difference Between Local and AWS

Local Argo CD uses:

```text
targetRevision: feature/platform-foundation
values file: values-local-cka.yaml
```

AWS EKS production demo will use:

```text
targetRevision: main or release branch
values file: values.yaml or values-prod-demo.yaml
```

The local test is for proving the GitOps workflow before using real AWS infrastructure.
