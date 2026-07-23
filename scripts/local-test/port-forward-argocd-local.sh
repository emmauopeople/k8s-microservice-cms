#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
LOCAL_PORT="${ARGOCD_LOCAL_PORT:-8081}"

cat <<MSG
Forwarding Argo CD UI to https://localhost:${LOCAL_PORT}

The browser may warn because Argo CD uses a self-signed local certificate.
Accept the warning for local testing.

Press Ctrl+C to stop.
MSG

kubectl -n "${NAMESPACE}" port-forward svc/argocd-server "${LOCAL_PORT}:443"
