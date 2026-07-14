#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-church-prod}"
RELEASE_NAME="${RELEASE_NAME:-church-app}"
CHART_PATH="${CHART_PATH:-helm/apps/church-app}"
VALUES_FILE="${VALUES_FILE:-helm/apps/church-app/values-local-cka.yaml}"
IMAGE_TAG="${IMAGE_TAG:-}"

if [[ -z "${IMAGE_TAG}" ]]; then
  echo "Missing IMAGE_TAG. Example: IMAGE_TAG=prod-abc1234 ./scripts/local-test/deploy-church-app-local.sh" >&2
  exit 1
fi

helm upgrade --install "${RELEASE_NAME}" "${CHART_PATH}" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  -f "${VALUES_FILE}" \
  --set services.frontend.image.tag="${IMAGE_TAG}" \
  --set services.auth-service.image.tag="${IMAGE_TAG}" \
  --set services.church-core-service.image.tag="${IMAGE_TAG}" \
  --set services.document-service.image.tag="${IMAGE_TAG}"

kubectl -n "${NAMESPACE}" rollout status deployment/frontend --timeout=180s
kubectl -n "${NAMESPACE}" rollout status deployment/auth-service --timeout=180s
kubectl -n "${NAMESPACE}" rollout status deployment/church-core-service --timeout=180s
kubectl -n "${NAMESPACE}" rollout status deployment/document-service --timeout=180s

kubectl -n "${NAMESPACE}" get pods -o wide
kubectl -n "${NAMESPACE}" get svc
