#!/usr/bin/env bash
set -euo pipefail

# Restores portable custom-format PostgreSQL dumps into the AWS RDS PostgreSQL instance.
# Run this only after RDS is available and network access to RDS is configured.
# No credentials are stored in this script.
#
# Required environment variables:
#   RDS_PGHOST        RDS PostgreSQL endpoint hostname
#   RDS_PGUSER        RDS master/admin user or migration user
#   PGPASSWORD        PostgreSQL password for RDS_PGUSER
#   BACKUP_SET_DIR    Directory containing auth_db.dump, church_core_db.dump, document_core_db.dump
#
# Optional environment variables:
#   RDS_PGPORT        Defaults to 5432
#   RDS_PGSSLMODE     Defaults to require
#   DATABASES         Space-separated database list. Defaults to church app databases.
#   RESTORE_CLEAN     Defaults to true. Uses --clean --if-exists before restore.

: "${RDS_PGHOST:?Missing required environment variable: RDS_PGHOST}"
: "${RDS_PGUSER:?Missing required environment variable: RDS_PGUSER}"
: "${PGPASSWORD:?Missing required environment variable: PGPASSWORD}"
: "${BACKUP_SET_DIR:?Missing required environment variable: BACKUP_SET_DIR}"

RDS_PGPORT="${RDS_PGPORT:-5432}"
RDS_PGSSLMODE="${RDS_PGSSLMODE:-require}"
DATABASES="${DATABASES:-auth_db church_core_db document_core_db}"
RESTORE_CLEAN="${RESTORE_CLEAN:-true}"

if [[ ! -d "${BACKUP_SET_DIR}" ]]; then
  echo "Backup directory does not exist: ${BACKUP_SET_DIR}" >&2
  exit 1
fi

export PGHOST="${RDS_PGHOST}"
export PGPORT="${RDS_PGPORT}"
export PGUSER="${RDS_PGUSER}"
export PGSSLMODE="${RDS_PGSSLMODE}"

create_database_if_missing() {
  local db="$1"
  if psql --dbname=postgres --tuples-only --no-align --command="SELECT 1 FROM pg_database WHERE datname='${db}';" | grep -q '^1$'; then
    echo "Database already exists: ${db}"
  else
    echo "Creating database: ${db}"
    psql --dbname=postgres --command="CREATE DATABASE ${db};"
  fi
}

for db in ${DATABASES}; do
  dump_file="${BACKUP_SET_DIR}/${db}.dump"
  if [[ ! -f "${dump_file}" ]]; then
    echo "Missing dump file: ${dump_file}" >&2
    exit 1
  fi

  create_database_if_missing "${db}"

  echo "Restoring ${dump_file} into ${db}"
  if [[ "${RESTORE_CLEAN}" == "true" ]]; then
    pg_restore \
      --verbose \
      --clean \
      --if-exists \
      --no-owner \
      --no-acl \
      --dbname="${db}" \
      "${dump_file}"
  else
    pg_restore \
      --verbose \
      --no-owner \
      --no-acl \
      --dbname="${db}" \
      "${dump_file}"
  fi
done

echo "Restore completed for: ${DATABASES}"
