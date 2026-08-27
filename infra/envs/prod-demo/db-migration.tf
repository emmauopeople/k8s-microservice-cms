check "db_migration_host_requires_storage" {
  assert {
    condition     = !var.enable_db_migration_host || var.enable_db_migration_storage
    error_message = "enable_db_migration_host=true requires enable_db_migration_storage=true."
  }
}

module "db_migration" {
  count  = var.enable_db_migration_storage ? 1 : 0
  source = "../../modules/db-migration"

  name = "${local.name_prefix}-db-migration"

  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = module.vpc.vpc_cidr_block
  private_subnet_id       = module.vpc.private_app_subnet_ids[0]
  private_route_table_ids = module.vpc.private_app_route_table_ids

  rds_security_group_id = module.rds_postgres.db_security_group_id
  database_port         = 5432

  create_instance  = var.enable_db_migration_host
  instance_type    = var.db_migration_instance_type
  root_volume_size = var.db_migration_root_volume_size

  backup_expiration_days             = var.db_migration_backup_expiration_days
  noncurrent_version_expiration_days = var.db_migration_noncurrent_expiration_days
  force_destroy                      = var.db_migration_bucket_force_destroy

  tags = local.common_tags
}
