# OVHcloud PostgreSQL to AWS RDS Backup and Restore Runbook

This runbook prepares the current OVHcloud PostgreSQL databases for migration into the AWS RDS PostgreSQL instance used by the EKS demo environment.

No Terraform apply is required to use the OVH backup step. The RDS bootstrap and restore steps run later, after the AWS RDS instance is created.

## Databases

The church app currently uses three PostgreSQL databases:

| Service | Database | Backup file |
|---|---|---|
| auth-service | `auth_db` | `auth_db.dump` |
| church-core-service | `church_core_db` | `church_core_db.dump` |
| document-service | `document_core_db` | `document_core_db.dump` |

## 1. Backup from OVHcloud

Run this from a workstation or trusted jump host that can connect to the OVHcloud PostgreSQL server.

```bash
cd /e/church_application/k8s-microservice-cms
chmod +x scripts/backup/backup-ovh-postgres-databases.sh

export OVH_PGHOST='<ovh-postgres-host-or-ip>'
export OVH_PGPORT='5432'
export OVH_PGUSER='<ovh-postgres-user>'
export PGPASSWORD='<ovh-postgres-password>'
export OVH_PGSSLMODE='prefer'

./scripts/backup/backup-ovh-postgres-databases.sh
```

The script creates a timestamped backup set:

```text
backups/ovh-postgres/YYYYMMDDTHHMMSSZ/
  auth_db.dump
  church_core_db.dump
  document_core_db.dump
  manifest.txt
```

It also creates a compressed archive:

```text
backups/ovh-postgres/ovh-postgres-YYYYMMDDTHHMMSSZ.tar.gz
```

## 2. Optional: upload the backup archive to S3

If an S3 bucket is already available for temporary migration storage, set `BACKUP_S3_URI`:

```bash
export BACKUP_S3_URI='s3://<bucket-name>/database-migration/ovh-postgres'
./scripts/backup/backup-ovh-postgres-databases.sh
```

Do not commit backup files or database dumps to Git.

## 3. After Terraform apply: bootstrap RDS app databases and users

Run this only after the RDS instance exists and your machine can connect to it.

```bash
chmod +x scripts/rds/bootstrap-rds-app-databases.sh

export RDS_PGHOST='<rds-endpoint-hostname>'
export RDS_PGPORT='5432'
export RDS_PGUSER='cms_admin'
export PGPASSWORD='<rds-master-password>'
export RDS_PGSSLMODE='require'

export AUTH_DB_PASSWORD='<new-auth-db-user-password>'
export CHURCH_CORE_DB_PASSWORD='<new-church-core-db-user-password>'
export DOCUMENT_DB_PASSWORD='<new-document-db-user-password>'

./scripts/rds/bootstrap-rds-app-databases.sh
```

This creates or updates:

```text
auth_db
church_core_db
document_core_db

auth_db_user
church_core_db_user
document_core_db_user
```

## 4. Restore backups into RDS

Point `BACKUP_SET_DIR` to the timestamped backup folder containing the `.dump` files.

```bash
chmod +x scripts/restore/restore-postgres-databases-to-rds.sh

export RDS_PGHOST='<rds-endpoint-hostname>'
export RDS_PGPORT='5432'
export RDS_PGUSER='cms_admin'
export PGPASSWORD='<rds-master-password>'
export RDS_PGSSLMODE='require'
export BACKUP_SET_DIR='./backups/ovh-postgres/YYYYMMDDTHHMMSSZ'

./scripts/restore/restore-postgres-databases-to-rds.sh
```

The restore script uses `pg_restore --no-owner --no-acl` so the dump can be restored into RDS without preserving OVH-specific ownership.

## 5. Create Kubernetes secrets for the app

After restoring data, create Kubernetes secrets in the EKS cluster using RDS app-user connection strings.

```bash
chmod +x scripts/eks/create-church-app-secrets-from-rds.sh

export RDS_HOST='<rds-endpoint-hostname>'
export RDS_PORT='5432'
export PGSSLMODE='require'
export JWT_SECRET_VALUE='<strong-shared-jwt-secret>'

export AUTH_DB_PASSWORD='<new-auth-db-user-password>'
export CHURCH_CORE_DB_PASSWORD='<new-church-core-db-user-password>'
export DOCUMENT_DB_PASSWORD='<new-document-db-user-password>'

./scripts/eks/create-church-app-secrets-from-rds.sh
```

The script creates the six Kubernetes secrets expected by the Helm chart:

```text
auth-service-db
church-core-service-db
document-service-db
auth-service-secret
church-core-service-secret
document-service-secret
```

## 6. Validation checks

After restore and secret creation:

```bash
kubectl -n church-prod get secrets
kubectl -n church-prod rollout status deploy/auth-service
kubectl -n church-prod rollout status deploy/church-core-service
kubectl -n church-prod rollout status deploy/document-service
kubectl -n church-prod exec deploy/auth-service -- wget -qO- http://localhost:4001/health/db
```

Expected result: all backend services should report healthy database connections.

## Notes

- Keep the OVH backup archive until the EKS/RDS demo is fully validated.
- Store database dump archives outside Git.
- Use different app-user passwords for each database.
- The current document-service still stores uploaded file bytes in PostgreSQL, so `document_core_db.dump` is important for restoring uploaded documents.
