#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
INSTALL_URL="${ARGOCD_INSTALL_URL:-https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml}"

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

# Use server-side apply to avoid the Kubernetes annotation size limit that can
# occur when client-side apply stores large Argo CD CRDs in last-applied-config.
kubectl apply --server-side --force-conflicts -n "${NAMESPACE}" -f "${INSTALL_URL}"

# In case an older client-side apply already stored oversized last-applied
# annotations on CRDs, remove them. Ignore missing CRDs during first install.
for crd in applications.argoproj.io applicationsets.argoproj.io appprojects.argoproj.io; do
  kubectl annotate crd "${crd}" kubectl.kubernetes.io/last-applied-configuration- >/dev/null 2>&1 || true
done

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
