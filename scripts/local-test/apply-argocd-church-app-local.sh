#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
APP_NAMESPACE="${APP_NAMESPACE:-church-prod}"
APP_NAME="${APP_NAME:-church-app-local}"
REPO_URL="${REPO_URL:-https://github.com/emmauopeople/k8s-microservice-cms.git}"
TARGET_REVISION="${TARGET_REVISION:-feature/platform-foundation}"
CHART_PATH="${CHART_PATH:-helm/apps/church-app}"
VALUES_FILE="${VALUES_FILE:-values-local-cka.yaml}"
IMAGE_TAG_VALUES_FILE="${IMAGE_TAG_VALUES_FILE:-values-image-tags.yaml}"
IMAGE_TAG="${IMAGE_TAG:-}"

kubectl get namespace "${ARGOCD_NAMESPACE}" >/dev/null 2>&1 || {
  echo "Argo CD namespace '${ARGOCD_NAMESPACE}' does not exist. Run ./scripts/local-test/install-argocd-local.sh first." >&2
  exit 1
}

if [[ -n "${IMAGE_TAG}" ]]; then
  echo "Applying '${APP_NAME}' with temporary image tag override: ${IMAGE_TAG}"
else
  echo "Applying '${APP_NAME}' using GitOps image tag values file: ${IMAGE_TAG_VALUES_FILE}"
fi

cat <<EOF > /tmp/church-app-local-argocd.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
  namespace: ${ARGOCD_NAMESPACE}
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: ${APP_NAMESPACE}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${TARGET_REVISION}
    path: ${CHART_PATH}
    helm:
      releaseName: church-app
      valueFiles:
        - ${VALUES_FILE}
        - ${IMAGE_TAG_VALUES_FILE}
EOF

if [[ -n "${IMAGE_TAG}" ]]; then
  cat <<EOF >> /tmp/church-app-local-argocd.yaml
      parameters:
        - name: services.frontend.image.tag
          value: ${IMAGE_TAG}
        - name: services.auth-service.image.tag
          value: ${IMAGE_TAG}
        - name: services.church-core-service.image.tag
          value: ${IMAGE_TAG}
        - name: services.document-service.image.tag
          value: ${IMAGE_TAG}
EOF
fi

kubectl apply -f /tmp/church-app-local-argocd.yaml

rm -f /tmp/church-app-local-argocd.yaml

echo
echo "Applied Argo CD application '${APP_NAME}'."
echo "Waiting briefly for Argo CD to reconcile..."
sleep 10

kubectl -n "${ARGOCD_NAMESPACE}" get applications.argoproj.io "${APP_NAME}" -o wide || true

echo
echo "Application status:"
kubectl -n "${ARGOCD_NAMESPACE}" get applications.argoproj.io "${APP_NAME}" \
  -o jsonpath='sync={.status.sync.status} health={.status.health.status}{"\n"}' || true

echo
echo "Church app workloads:"
kubectl -n "${APP_NAMESPACE}" get deploy,pods,svc || true
