#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
RELEASE_NAME="${MONITORING_RELEASE_NAME:-monitoring}"
CHART_VERSION="${KUBE_PROMETHEUS_STACK_VERSION:-87.12.0}"
VALUES_FILE="${VALUES_FILE:-helm/addons/monitoring/kube-prometheus-stack-values-local.yaml}"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required but was not found in PATH." >&2
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required but was not found in PATH." >&2
  exit 1
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update

helm upgrade --install "${RELEASE_NAME}" prometheus-community/kube-prometheus-stack \
  --namespace "${NAMESPACE}" \
  --version "${CHART_VERSION}" \
  -f "${VALUES_FILE}" \
  --wait \
  --timeout 10m

kubectl -n "${NAMESPACE}" get pods
kubectl -n "${NAMESPACE}" get svc

echo
echo "Prometheus/Grafana installed. Next run:"
echo "  ./scripts/local-test/enable-app-metrics-local.sh"
