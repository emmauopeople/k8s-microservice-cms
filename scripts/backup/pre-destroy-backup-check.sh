#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="prod-demo"
RDS_INSTANCE_ID="church-prod-demo-postgres"
NAMESPACES="church-prod,monitoring,logging,argocd"
BACKUP_NAME="pre-destroy-${ENVIRONMENT}-$(date +%Y%m%d%H%M)"
SNAPSHOT_ID="${RDS_INSTANCE_ID}-final-$(date +%Y%m%d%H%M)"

echo "Pre-destroy backup checklist for ${ENVIRONMENT}"
echo "This script prints and runs safety checks before destroying the demo environment."
echo

echo "1. Kubernetes context:"
kubectl config current-context

echo
echo "2. Pods summary:"
kubectl get pods -A

echo
echo "3. Velero backup storage location:"
velero backup-location get || true

echo
echo "4. Creating Velero backup: ${BACKUP_NAME}"
velero backup create "${BACKUP_NAME}" --include-namespaces "${NAMESPACES}"

echo
echo "5. Creating RDS manual snapshot: ${SNAPSHOT_ID}"
aws rds create-db-snapshot \
  --db-instance-identifier "${RDS_INSTANCE_ID}" \
  --db-snapshot-identifier "${SNAPSHOT_ID}"

echo
echo "6. Review backup status:"
echo "velero backup describe ${BACKUP_NAME}"
echo "aws rds describe-db-snapshots --db-snapshot-identifier ${SNAPSHOT_ID}"
