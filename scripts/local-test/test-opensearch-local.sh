#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${LOGGING_NAMESPACE:-logging}"

kubectl -n "${NAMESPACE}" get pods

OPENSEARCH_POD="$(kubectl -n "${NAMESPACE}" get pod -l app.kubernetes.io/name=opensearch -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [[ -z "${OPENSEARCH_POD}" ]]; then
  OPENSEARCH_POD="$(kubectl -n "${NAMESPACE}" get pod -l app=opensearch-master -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
fi

if [[ -z "${OPENSEARCH_POD}" ]]; then
  echo "Could not find OpenSearch pod in namespace ${NAMESPACE}" >&2
  exit 1
fi

echo "Testing OpenSearch cluster health"
kubectl -n "${NAMESPACE}" exec "${OPENSEARCH_POD}" -- curl -s http://localhost:9200/_cluster/health?pretty

echo
echo "Testing log indices"
kubectl -n "${NAMESPACE}" exec "${OPENSEARCH_POD}" -- curl -s http://localhost:9200/_cat/indices/kubernetes-*?v || true

echo
echo "Testing recent church-prod logs"
kubectl -n "${NAMESPACE}" exec "${OPENSEARCH_POD}" -- curl -s -H 'Content-Type: application/json' \
  http://localhost:9200/kubernetes-*/_search \
  -d '{"size":5,"sort":[{"@timestamp":{"order":"desc"}}],"query":{"match_phrase":{"kubernetes.namespace_name":"church-prod"}}}'
