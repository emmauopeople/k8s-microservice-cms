#!/usr/bin/env bash
set -euo pipefail

# Creates Kubernetes secrets for the church app using RDS PostgreSQL connection strings.
# Run after RDS app users are created and after kubectl points to the EKS cluster.
# No credentials are stored in this script.
#
# Required environment variables:
#   RDS_HOST                  RDS hostname without port
#   AUTH_DB_PASSWORD          Password for auth_db_user
#   CHURCH_CORE_DB_PASSWORD   Password for church_db_user
#   DOCUMENT_DB_PASSWORD      Password for document_db_user
#   JWT_SECRET_VALUE          Shared JWT secret used by the backend services
#
# Optional environment variables:
#   RDS_PORT                  Defaults to 5432
#   NAMESPACE                 Defaults to church-prod
#   PGSSLMODE                 Defaults to require
#   AUTH_DB_USER              Defaults to auth_db_user
#   CHURCH_CORE_DB_USER       Defaults to church_db_user
#   DOCUMENT_DB_USER          Defaults to document_db_user

: "${RDS_HOST:?Missing required environment variable: RDS_HOST}"
: "${AUTH_DB_PASSWORD:?Missing required environment variable: AUTH_DB_PASSWORD}"
: "${CHURCH_CORE_DB_PASSWORD:?Missing required environment variable: CHURCH_CORE_DB_PASSWORD}"
: "${DOCUMENT_DB_PASSWORD:?Missing required environment variable: DOCUMENT_DB_PASSWORD}"
: "${JWT_SECRET_VALUE:?Missing required environment variable: JWT_SECRET_VALUE}"

NAMESPACE="${NAMESPACE:-church-prod}"
RDS_PORT="${RDS_PORT:-5432}"
PGSSLMODE="${PGSSLMODE:-require}"
AUTH_DB_USER="${AUTH_DB_USER:-auth_db_user}"
CHURCH_CORE_DB_USER="${CHURCH_CORE_DB_USER:-church_db_user}"
DOCUMENT_DB_USER="${DOCUMENT_DB_USER:-document_db_user}"

AUTH_DATABASE_URL="postgresql://${AUTH_DB_USER}:${AUTH_DB_PASSWORD}@${RDS_HOST}:${RDS_PORT}/auth_db?sslmode=${PGSSLMODE}"
CHURCH_CORE_DATABASE_URL="postgresql://${CHURCH_CORE_DB_USER}:${CHURCH_CORE_DB_PASSWORD}@${RDS_HOST}:${RDS_PORT}/church_core_db?sslmode=${PGSSLMODE}"
DOCUMENT_DATABASE_URL="postgresql://${DOCUMENT_DB_USER}:${DOCUMENT_DB_PASSWORD}@${RDS_HOST}:${RDS_PORT}/document_core_db?sslmode=${PGSSLMODE}"

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

echo "Church app Kubernetes secrets created/updated in namespace: ${NAMESPACE}"
