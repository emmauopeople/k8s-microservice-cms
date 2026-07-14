#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-monitoring}"
DASHBOARD_FILE="${DASHBOARD_FILE:-dashboards/grafana/church-app-local-dashboard.json}"
CONFIGMAP_NAME="${CONFIGMAP_NAME:-church-app-local-grafana-dashboard}"

if [[ ! -f "${DASHBOARD_FILE}" ]]; then
  echo "Missing dashboard file: ${DASHBOARD_FILE}" >&2
  exit 1
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create configmap "${CONFIGMAP_NAME}" \
  --from-file=church-app-local-dashboard.json="${DASHBOARD_FILE}" \
  --dry-run=client -o yaml \
  | kubectl label --local -f - grafana_dashboard=1 -o yaml \
  | kubectl apply -f -

echo "Applied Grafana dashboard ConfigMap: ${CONFIGMAP_NAME}"
echo "If the dashboard does not appear immediately, restart Grafana or wait for the dashboard sidecar to rescan."
