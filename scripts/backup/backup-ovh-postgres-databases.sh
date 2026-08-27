#!/usr/bin/env bash
set -euo pipefail

# Backs up the current OVHcloud PostgreSQL databases into portable custom-format dumps.
# No credentials are stored in this script.
#
# Required environment variables:
#   OVH_PGHOST       PostgreSQL host/IP on OVHcloud
#   OVH_PGUSER       PostgreSQL user with read access to the databases
#   PGPASSWORD       PostgreSQL password for OVH_PGUSER
#
# Optional environment variables:
#   OVH_PGPORT       Defaults to 5432
#   OVH_PGSSLMODE    Defaults to prefer
#   BACKUP_DIR       Defaults to ./backups/ovh-postgres
#   BACKUP_S3_URI    Optional S3 URI, for example s3://my-bucket/path
#   DATABASES        Space-separated database list. Defaults to the church app databases.

: "${OVH_PGHOST:?Missing required environment variable: OVH_PGHOST}"
: "${OVH_PGUSER:?Missing required environment variable: OVH_PGUSER}"
: "${PGPASSWORD:?Missing required environment variable: PGPASSWORD}"

OVH_PGPORT="${OVH_PGPORT:-5432}"
OVH_PGSSLMODE="${OVH_PGSSLMODE:-prefer}"
BACKUP_DIR="${BACKUP_DIR:-./backups/ovh-postgres}"
DATABASES="${DATABASES:-auth_db church_core_db document_core_db}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_SET_DIR="${BACKUP_DIR}/${TIMESTAMP}"
MANIFEST_FILE="${BACKUP_SET_DIR}/manifest.txt"

mkdir -p "${BACKUP_SET_DIR}"

export PGHOST="${OVH_PGHOST}"
export PGPORT="${OVH_PGPORT}"
export PGUSER="${OVH_PGUSER}"
export PGSSLMODE="${OVH_PGSSLMODE}"

echo "Backup set: ${BACKUP_SET_DIR}"
{
  echo "backup_timestamp_utc=${TIMESTAMP}"
  echo "source_host=${OVH_PGHOST}"
  echo "source_port=${OVH_PGPORT}"
  echo "source_user=${OVH_PGUSER}"
  echo "databases=${DATABASES}"
  echo
} > "${MANIFEST_FILE}"

for db in ${DATABASES}; do
  out_file="${BACKUP_SET_DIR}/${db}.dump"
  echo "Backing up database: ${db} -> ${out_file}"

  pg_dump \
    --format=custom \
    --verbose \
    --no-owner \
    --no-acl \
    --dbname="${db}" \
    --file="${out_file}"

  sha256sum "${out_file}" | tee -a "${MANIFEST_FILE}"
done

# Compress a copy of the backup set for transfer/storage convenience.
archive_file="${BACKUP_DIR}/ovh-postgres-${TIMESTAMP}.tar.gz"
tar -C "${BACKUP_DIR}" -czf "${archive_file}" "${TIMESTAMP}"
sha256sum "${archive_file}" | tee -a "${MANIFEST_FILE}"

echo
echo "Backup completed."
echo "Backup directory: ${BACKUP_SET_DIR}"
echo "Archive: ${archive_file}"

if [[ -n "${BACKUP_S3_URI:-}" ]]; then
  echo "Uploading archive to ${BACKUP_S3_URI}/"
  aws s3 cp "${archive_file}" "${BACKUP_S3_URI}/"
  aws s3 cp "${MANIFEST_FILE}" "${BACKUP_S3_URI}/manifest-${TIMESTAMP}.txt"
  echo "S3 upload completed."
fi
