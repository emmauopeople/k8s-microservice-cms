#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
SERVICE_NAME="${PROMETHEUS_SERVICE_NAME:-monitoring-kube-prometheus-prometheus}"
LOCAL_PORT="${PROMETHEUS_LOCAL_PORT:-9090}"
REMOTE_PORT="${PROMETHEUS_REMOTE_PORT:-9090}"

echo "Opening Prometheus on http://localhost:${LOCAL_PORT}"
echo "Targets page: http://localhost:${LOCAL_PORT}/targets"
echo "Query page:   http://localhost:${LOCAL_PORT}/graph"
echo
echo "Press Ctrl+C to stop port-forwarding."

kubectl -n "${NAMESPACE}" port-forward "svc/${SERVICE_NAME}" "${LOCAL_PORT}:${REMOTE_PORT}"
