module "velero" {
  source = "../../modules/velero"

  name = "${local.name_prefix}-velero-backups"

  oidc_provider_arn = module.irsa.oidc_provider_arn
  oidc_issuer_url   = module.eks.cluster_oidc_issuer_url

  namespace            = "velero"
  service_account_name = "velero"

  force_destroy                        = true
  backup_expiration_days               = 14
  noncurrent_version_expiration_days   = 30
  abort_incomplete_multipart_upload_days = 7

  tags = local.common_tags
}
