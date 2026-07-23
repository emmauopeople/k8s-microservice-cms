#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-church-prod}"

check_service() {
  local service="$1"
  local port="$2"

  echo "Testing ${service} /health"
  kubectl -n "${NAMESPACE}" run "curl-${service}-health" \
    --rm -i --restart=Never \
    --image=curlimages/curl:8.11.1 \
    --command -- curl -fsS "http://${service}:${port}/health"

  echo

  if [[ "${service}" != "frontend" ]]; then
    echo "Testing ${service} /health/db"
    kubectl -n "${NAMESPACE}" run "curl-${service}-db" \
      --rm -i --restart=Never \
      --image=curlimages/curl:8.11.1 \
      --command -- curl -fsS "http://${service}:${port}/health/db"

    echo

    echo "Testing ${service} /metrics"
    kubectl -n "${NAMESPACE}" run "curl-${service}-metrics" \
      --rm -i --restart=Never \
      --image=curlimages/curl:8.11.1 \
      --command -- sh -c "curl -fsS http://${service}:${port}/metrics | head -30"

    echo
  fi
}

kubectl -n "${NAMESPACE}" get pods
kubectl -n "${NAMESPACE}" get svc

check_service frontend 8080
check_service auth-service 4001
check_service church-core-service 4002
check_service document-service 4003
