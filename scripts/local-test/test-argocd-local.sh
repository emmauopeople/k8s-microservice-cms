#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
APP_NAMESPACE="${APP_NAMESPACE:-church-prod}"
APP_NAME="${APP_NAME:-church-app-local}"

kubectl -n "${ARGOCD_NAMESPACE}" get applications.argoproj.io "${APP_NAME}" -o wide

echo
echo "Argo CD sync and health:"
kubectl -n "${ARGOCD_NAMESPACE}" get applications.argoproj.io "${APP_NAME}" \
  -o jsonpath='sync={.status.sync.status} health={.status.health.status}{"\n"}'

echo
echo "Application resources from Argo CD perspective:"
kubectl -n "${ARGOCD_NAMESPACE}" get applications.argoproj.io "${APP_NAME}" \
  -o jsonpath='{range .status.resources[*]}{.kind}{"\t"}{.namespace}{"\t"}{.name}{"\t"}{.status}{"\t"}{.health.status}{"\n"}{end}' || true

echo
echo "Kubernetes workloads:"
kubectl -n "${APP_NAMESPACE}" get deploy,pods,svc -o wide

echo
echo "Recent app events:"
kubectl -n "${APP_NAMESPACE}" get events --sort-by=.lastTimestamp | tail -30
