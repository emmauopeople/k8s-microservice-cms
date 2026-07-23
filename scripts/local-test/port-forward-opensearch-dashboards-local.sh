#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${LOGGING_NAMESPACE:-logging}"
LOCAL_PORT="${LOCAL_PORT:-5601}"
SERVICE_NAME="${SERVICE_NAME:-opensearch-dashboards}"

kubectl -n "${NAMESPACE}" port-forward "svc/${SERVICE_NAME}" "${LOCAL_PORT}:5601"
