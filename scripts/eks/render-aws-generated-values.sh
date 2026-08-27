#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TF_DIR="${TF_DIR:-${REPO_ROOT}/infra/envs/prod-demo}"
OUTPUT_FILE="${OUTPUT_FILE:-${REPO_ROOT}/helm/apps/church-app/values-aws-generated.yaml}"

command -v terraform >/dev/null 2>&1 || {
  echo "terraform is required." >&2
  exit 1
}

read_output() {
  local name="$1"
  terraform -chdir="${TF_DIR}" output -raw "${name}"
}

ACM_CERTIFICATE_ARN="$(read_output acm_certificate_arn)"
WAF_WEB_ACL_ARN="$(read_output waf_web_acl_arn)"
DOCUMENT_SERVICE_ROLE_ARN="$(read_output irsa_document_service_s3_role_arn)"

for value_name in ACM_CERTIFICATE_ARN WAF_WEB_ACL_ARN DOCUMENT_SERVICE_ROLE_ARN; do
  if [[ -z "${!value_name}" ]]; then
    echo "Terraform output produced an empty value for ${value_name}." >&2
    exit 1
  fi
done

cat > "${OUTPUT_FILE}" <<EOF
# Generated from Terraform outputs. These ARNs are deployment metadata, not secrets.
ingress:
  certificateArn: "${ACM_CERTIFICATE_ARN}"
  wafAclArn: "${WAF_WEB_ACL_ARN}"

serviceAccounts:
  document-service:
    annotations:
      eks.amazonaws.com/role-arn: "${DOCUMENT_SERVICE_ROLE_ARN}"
EOF

echo "Generated ${OUTPUT_FILE}"
echo "Review and commit this file before syncing church-app in Argo CD."
