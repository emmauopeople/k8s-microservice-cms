#!/usr/bin/env bash
set -euo pipefail

# Downloads one database backup set from the private migration bucket onto the
# SSM-managed EC2 migration host and verifies SHA-256 checksums.
#
# Required:
#   MIGRATION_BUCKET
#   MIGRATION_PREFIX
#
# Optional:
#   DEST_DIR              Defaults to /opt/church-db-migration/<prefix-name>

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
required_var MIGRATION_PREFIX

prefix_name="${MIGRATION_PREFIX%/}"
prefix_name="${prefix_name##*/}"
DEST_DIR="${DEST_DIR:-/opt/church-db-migration/${prefix_name}}"

mkdir -p "${DEST_DIR}"
chmod 0700 "${DEST_DIR}"

aws s3 sync \
  "s3://${MIGRATION_BUCKET}/${MIGRATION_PREFIX%/}/" \
  "${DEST_DIR}/" \
  --only-show-errors

if [[ ! -f "${DEST_DIR}/checksums.sha256" ]]; then
  echo "Missing checksums.sha256 in downloaded backup set." >&2
  exit 1
fi

(
  cd "${DEST_DIR}"
  sha256sum --check checksums.sha256
)

echo
echo "Backup set downloaded and verified: ${DEST_DIR}"
ls -lh "${DEST_DIR}"
