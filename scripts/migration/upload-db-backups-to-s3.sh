#!/usr/bin/env bash
set -euo pipefail

# Uploads an explicit PostgreSQL backup set from a local PC to the private
# Terraform-managed migration bucket. Unrelated files in the source directory
# are not uploaded.
#
# Required:
#   MIGRATION_BUCKET      Terraform output: db_migration_bucket_name
#
# Optional:
#   SOURCE_DIR            Defaults to ./db_backups
#   MIGRATION_PREFIX      Defaults to ovh-backup-<UTC timestamp>
#   BACKUP_FILES          Space-separated file list

required_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required environment variable: ${name}" >&2
    exit 1
  fi
}

command -v aws >/dev/null 2>&1 || {
  echo "AWS CLI is required." >&2
  exit 1
}

command -v sha256sum >/dev/null 2>&1 || {
  echo "sha256sum is required." >&2
  exit 1
}

required_var MIGRATION_BUCKET

SOURCE_DIR="${SOURCE_DIR:-./db_backups}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
MIGRATION_PREFIX="${MIGRATION_PREFIX:-ovh-backup-${TIMESTAMP}}"
BACKUP_FILES="${BACKUP_FILES:-auth_db.sql church_core_db.sql document_core_db.sql}"
CHECKSUM_FILE="${SOURCE_DIR}/checksums-${TIMESTAMP}.sha256"
MANIFEST_FILE="${SOURCE_DIR}/manifest-${TIMESTAMP}.txt"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Source directory does not exist: ${SOURCE_DIR}" >&2
  exit 1
fi

: > "${CHECKSUM_FILE}"
{
  echo "created_at_utc=${TIMESTAMP}"
  echo "source_directory=${SOURCE_DIR}"
  echo "destination=s3://${MIGRATION_BUCKET}/${MIGRATION_PREFIX}/"
  echo "backup_files=${BACKUP_FILES}"
} > "${MANIFEST_FILE}"

for file in ${BACKUP_FILES}; do
  path="${SOURCE_DIR}/${file}"
  if [[ ! -f "${path}" ]]; then
    echo "Missing backup file: ${path}" >&2
    exit 1
  fi

  (
    cd "${SOURCE_DIR}"
    sha256sum "${file}"
  ) >> "${CHECKSUM_FILE}"
done

for file in ${BACKUP_FILES}; do
  echo "Uploading ${file}"
  aws s3 cp \
    "${SOURCE_DIR}/${file}" \
    "s3://${MIGRATION_BUCKET}/${MIGRATION_PREFIX}/${file}" \
    --only-show-errors
 done

aws s3 cp \
  "${CHECKSUM_FILE}" \
  "s3://${MIGRATION_BUCKET}/${MIGRATION_PREFIX}/checksums.sha256" \
  --only-show-errors

aws s3 cp \
  "${MANIFEST_FILE}" \
  "s3://${MIGRATION_BUCKET}/${MIGRATION_PREFIX}/manifest.txt" \
  --only-show-errors

echo
aws s3 ls "s3://${MIGRATION_BUCKET}/${MIGRATION_PREFIX}/"
echo
echo "Backup set uploaded to s3://${MIGRATION_BUCKET}/${MIGRATION_PREFIX}/"
echo "Save the migration prefix: ${MIGRATION_PREFIX}"
