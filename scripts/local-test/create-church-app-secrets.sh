#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-church-prod}"
JWT_SECRET_VALUE="${JWT_SECRET_VALUE:-change-this-secret-before-production}"

required_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required environment variable: ${name}" >&2
    exit 1
  fi
}

required_var AUTH_DATABASE_URL
required_var CHURCH_CORE_DATABASE_URL
required_var DOCUMENT_DATABASE_URL

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic auth-service-db \
  --from-literal=DATABASE_URL="${AUTH_DATABASE_URL}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic church-core-service-db \
  --from-literal=DATABASE_URL="${CHURCH_CORE_DATABASE_URL}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic document-service-db \
  --from-literal=DATABASE_URL="${DOCUMENT_DATABASE_URL}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic auth-service-secret \
  --from-literal=JWT_SECRET="${JWT_SECRET_VALUE}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic church-core-service-secret \
  --from-literal=JWT_SECRET="${JWT_SECRET_VALUE}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic document-service-secret \
  --from-literal=JWT_SECRET="${JWT_SECRET_VALUE}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" get secrets \
  auth-service-db \
  church-core-service-db \
  document-service-db \
  auth-service-secret \
  church-core-service-secret \
  document-service-secret
