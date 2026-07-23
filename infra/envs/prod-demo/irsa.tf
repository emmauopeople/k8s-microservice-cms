module "irsa" {
  source = "../../modules/irsa"

  cluster_name    = module.eks.cluster_name
  oidc_issuer_url = module.eks.cluster_oidc_issuer_url

  route53_zone_id     = module.acm_route53.zone_id
  document_bucket_arn = module.s3_documents.bucket_arn

  secrets_manager_secret_arns = [
    module.rds_postgres.master_user_secret_arn
  ]

  aws_load_balancer_controller_namespace       = "kube-system"
  aws_load_balancer_controller_service_account = "aws-load-balancer-controller"

  external_dns_namespace       = "external-dns"
  external_dns_service_account = "external-dns"

  ebs_csi_namespace       = "kube-system"
  ebs_csi_service_account = "ebs-csi-controller-sa"

  document_service_namespace = "church-prod"
  document_service_account   = "document-service"

  app_secrets_namespace = "church-prod"
  app_secrets_service_accounts = [
    "auth-service",
    "church-core-service",
    "document-service"
  ]

  tags = local.common_tags
}
