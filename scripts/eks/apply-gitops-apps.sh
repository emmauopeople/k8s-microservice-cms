#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl is required." >&2
  exit 1
}

kubectl get namespace "${ARGOCD_NAMESPACE}" >/dev/null 2>&1 || {
  echo "Argo CD namespace '${ARGOCD_NAMESPACE}' does not exist." >&2
  echo "Run scripts/eks/bootstrap-argocd.sh first." >&2
  exit 1
}

apps=(
  "gitops/addons/storageclass-gp3.yaml"
  "gitops/addons/aws-load-balancer-controller.yaml"
  "gitops/addons/external-dns.yaml"
  "gitops/addons/monitoring.yaml"
  "gitops/addons/opensearch.yaml"
  "gitops/addons/opensearch-dashboards.yaml"
  "gitops/addons/fluent-bit.yaml"
  "gitops/addons/velero.yaml"
)

for relative_path in "${apps[@]}"; do
  manifest="${REPO_ROOT}/${relative_path}"
  if [[ ! -f "${manifest}" ]]; then
    echo "Missing GitOps manifest: ${manifest}" >&2
    exit 1
  fi

  echo "Applying ${relative_path}"
  kubectl apply -f "${manifest}"
done

echo
echo "Platform GitOps applications submitted to Argo CD."
echo "Wait for these applications to become Synced/Healthy before applying church-app."
echo
kubectl -n "${ARGOCD_NAMESPACE}" get applications.argoproj.io \
  storageclass-gp3 \
  aws-load-balancer-controller \
  external-dns \
  monitoring \
  opensearch \
  opensearch-dashboards \
  fluent-bit \
  velero \
  -o wide || true
