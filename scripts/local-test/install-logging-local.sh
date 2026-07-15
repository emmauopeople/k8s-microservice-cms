#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${LOGGING_NAMESPACE:-logging}"

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

helm repo add opensearch https://opensearch-project.github.io/helm-charts >/dev/null 2>&1 || true
helm repo add fluent https://fluent.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update

helm upgrade --install opensearch opensearch/opensearch \
  --namespace "${NAMESPACE}" \
  -f helm/addons/logging/opensearch-values-local.yaml \
  --wait \
  --timeout 10m

helm upgrade --install opensearch-dashboards opensearch/opensearch-dashboards \
  --namespace "${NAMESPACE}" \
  -f helm/addons/logging/opensearch-dashboards-values-local.yaml \
  --wait \
  --timeout 10m

helm upgrade --install fluent-bit fluent/fluent-bit \
  --namespace "${NAMESPACE}" \
  -f helm/addons/logging/fluent-bit-values-local.yaml \
  --wait \
  --timeout 5m

kubectl -n "${NAMESPACE}" get pods -o wide
kubectl -n "${NAMESPACE}" get svc
