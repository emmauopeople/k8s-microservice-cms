#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n "${NAMESPACE}" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD control plane..."
kubectl -n "${NAMESPACE}" rollout status deployment/argocd-redis --timeout=300s
kubectl -n "${NAMESPACE}" rollout status deployment/argocd-repo-server --timeout=300s
kubectl -n "${NAMESPACE}" rollout status deployment/argocd-server --timeout=300s
kubectl -n "${NAMESPACE}" rollout status deployment/argocd-applicationset-controller --timeout=300s
kubectl -n "${NAMESPACE}" rollout status statefulset/argocd-application-controller --timeout=300s

echo
echo "Argo CD pods:"
kubectl -n "${NAMESPACE}" get pods -o wide

echo
echo "Argo CD initial admin password:"
kubectl -n "${NAMESPACE}" get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d || true
echo
echo
echo "Start the UI with:"
echo "./scripts/local-test/port-forward-argocd-local.sh"
echo
echo "Then open: https://localhost:8081"
echo "Username: admin"
