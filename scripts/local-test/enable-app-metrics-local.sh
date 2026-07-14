#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-church-prod}"
RELEASE_NAME="${RELEASE_NAME:-church-app}"
CHART_PATH="${CHART_PATH:-helm/apps/church-app}"

if ! kubectl get crd servicemonitors.monitoring.coreos.com >/dev/null 2>&1; then
  echo "ServiceMonitor CRD not found. Install monitoring first:" >&2
  echo "  ./scripts/local-test/install-monitoring-local.sh" >&2
  exit 1
fi

helm upgrade "${RELEASE_NAME}" "${CHART_PATH}" \
  --namespace "${NAMESPACE}" \
  --reuse-values \
  --set serviceMonitor.enabled=true

kubectl -n "${NAMESPACE}" get servicemonitor

echo
echo "App ServiceMonitors enabled. Give Prometheus 1-2 minutes to discover targets."
echo "Then run:"
echo "  ./scripts/local-test/port-forward-prometheus-local.sh"
echo "  ./scripts/local-test/port-forward-grafana-local.sh"
