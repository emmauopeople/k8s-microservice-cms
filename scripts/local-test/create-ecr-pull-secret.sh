#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-church-prod}"
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-302530480617}"
SECRET_NAME="${SECRET_NAME:-ecr-registry-secret}"
ECR_SERVER="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" delete secret "${SECRET_NAME}" --ignore-not-found

kubectl -n "${NAMESPACE}" create secret docker-registry "${SECRET_NAME}" \
  --docker-server="${ECR_SERVER}" \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region "${AWS_REGION}")"

kubectl -n "${NAMESPACE}" get secret "${SECRET_NAME}"
