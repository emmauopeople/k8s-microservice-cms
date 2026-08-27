#!/usr/bin/env bash
set -euo pipefail

ARGOCD_VERSION="${ARGOCD_VERSION:-v3.5.1}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl is required." >&2
  exit 1
}

kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Argo CD ${ARGOCD_VERSION} from ${MANIFEST_URL}"
kubectl apply --server-side --force-conflicts -n "${ARGOCD_NAMESPACE}" -f "${MANIFEST_URL}"

kubectl -n "${ARGOCD_NAMESPACE}" rollout status deployment/argocd-server --timeout=5m
kubectl -n "${ARGOCD_NAMESPACE}" rollout status deployment/argocd-repo-server --timeout=5m
kubectl -n "${ARGOCD_NAMESPACE}" rollout status deployment/argocd-applicationset-controller --timeout=5m

kubectl -n "${ARGOCD_NAMESPACE}" get pods

echo "Argo CD ${ARGOCD_VERSION} is installed."
