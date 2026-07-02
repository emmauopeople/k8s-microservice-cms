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
