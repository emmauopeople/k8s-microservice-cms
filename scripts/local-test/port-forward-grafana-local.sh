#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
SERVICE_NAME="${GRAFANA_SERVICE_NAME:-monitoring-grafana}"
LOCAL_PORT="${GRAFANA_LOCAL_PORT:-3000}"
REMOTE_PORT="${GRAFANA_REMOTE_PORT:-80}"

echo "Opening Grafana on http://localhost:${LOCAL_PORT}"
echo "Username: admin"
echo "Password: admin"
echo
echo "Press Ctrl+C to stop port-forwarding."

kubectl -n "${NAMESPACE}" port-forward "svc/${SERVICE_NAME}" "${LOCAL_PORT}:${REMOTE_PORT}"
