#!/usr/bin/env bash
set -euo pipefail

MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
APP_NAMESPACE="${NAMESPACE:-church-prod}"
PROMETHEUS_SERVICE="${PROMETHEUS_SERVICE_NAME:-monitoring-kube-prometheus-prometheus}"

kubectl -n "${MONITORING_NAMESPACE}" get pods
kubectl -n "${APP_NAMESPACE}" get servicemonitor

echo
echo "Testing Prometheus API from inside the cluster"

kubectl -n "${MONITORING_NAMESPACE}" run curl-prometheus-api \
  --image=curlimages/curl:8.10.1 \
  --restart=Never \
  --rm -i \
  --command -- sh -c \
  "curl -s 'http://${PROMETHEUS_SERVICE}.${MONITORING_NAMESPACE}.svc.cluster.local:9090/api/v1/query?query=up' | head -c 2000 && echo"

echo
echo "Useful PromQL checks:"
echo "  up"
echo "  app_info"
echo "  http_requests_total"
echo "  http_request_duration_seconds_count"
