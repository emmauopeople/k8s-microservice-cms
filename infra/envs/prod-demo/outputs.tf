output "ecr_repository_names" {
  value = module.ecr.repository_names
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  value = module.ecr.repository_arns
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  value = module.vpc.private_db_subnet_ids
}

output "nat_gateway_ids" {
  value = module.vpc.nat_gateway_ids
}

output "rds_endpoint" {
  value = module.rds_postgres.db_endpoint
}

output "rds_security_group_id" {
  value = module.rds_postgres.db_security_group_id
}

output "rds_subnet_group_name" {
  value = module.rds_postgres.db_subnet_group_name
}

output "rds_application_database_names" {
  value = module.rds_postgres.application_database_names
}

output "rds_master_user_secret_arn" {
  value     = module.rds_postgres.master_user_secret_arn
  sensitive = true
}

output "document_bucket_name" {
  value = module.s3_documents.bucket_name
}

output "document_bucket_arn" {
  value = module.s3_documents.bucket_arn
}

output "document_bucket_regional_domain_name" {
  value = module.s3_documents.bucket_regional_domain_name
}

output "document_bucket_cors_enabled" {
  value = module.s3_documents.bucket_cors_enabled
}

output "dns_zone_id" {
  value = module.acm_route53.zone_id
}

output "dns_zone_name" {
  value = module.acm_route53.zone_name
}

output "dns_name_servers" {
  value = module.acm_route53.name_servers
}

output "acm_certificate_arn" {
  value = module.acm_route53.certificate_arn
}

output "acm_certificate_status" {
  value = module.acm_route53.certificate_status
}

output "acm_certificate_validation_record_fqdns" {
  value = module.acm_route53.certificate_validation_record_fqdns
}

output "acm_certificate_validation_enabled" {
  value = module.acm_route53.certificate_validation_enabled
}

output "waf_web_acl_id" {
  value = module.waf.web_acl_id
}

output "waf_web_acl_arn" {
  value = module.waf.web_acl_arn
}

output "waf_web_acl_name" {
  value = module.waf.web_acl_name
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_arn" {
  value = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "eks_node_group_name" {
  value = module.eks.node_group_name
}

output "eks_node_group_arn" {
  value = module.eks.node_group_arn
}

output "eks_cluster_log_group_name" {
  value = module.eks.cluster_log_group_name
}

output "irsa_oidc_provider_arn" {
  value = module.irsa.oidc_provider_arn
}

output "irsa_aws_load_balancer_controller_role_arn" {
  value = module.irsa.aws_load_balancer_controller_role_arn
}

output "irsa_external_dns_role_arn" {
  value = module.irsa.external_dns_role_arn
}

output "irsa_ebs_csi_role_arn" {
  value = module.irsa.ebs_csi_role_arn
}

output "irsa_document_service_s3_role_arn" {
  value = module.irsa.document_service_s3_role_arn
}

output "irsa_app_secrets_reader_role_arn" {
  value = module.irsa.app_secrets_reader_role_arn
}

output "irsa_app_secrets_reader_service_accounts" {
  value = module.irsa.app_secrets_reader_service_accounts
}

output "velero_backup_bucket_name" {
  value = module.velero.bucket_name
}

output "velero_backup_bucket_arn" {
  value = module.velero.bucket_arn
}

output "velero_iam_role_arn" {
  value = module.velero.iam_role_arn
}

output "velero_service_account_subject" {
  value = module.velero.service_account_subject
}
