module "rds_postgres" {
  source = "../../modules/rds-postgres"

  name                  = "${local.name_prefix}-postgres"
  vpc_id                = module.vpc.vpc_id
  private_db_subnet_ids = module.vpc.private_db_subnet_ids

  allowed_cidr_blocks = var.private_app_subnet_cidrs
  database_port       = 5432

  engine_version        = var.rds_engine_version
  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage

  initial_database_name = "auth_db"
  additional_database_names = [
    "church_core_db",
    "document_core_db"
  ]

  master_username         = "cms_admin"
  multi_az                = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention_period
  deletion_protection     = var.rds_deletion_protection

  skip_final_snapshot       = var.rds_skip_final_snapshot
  final_snapshot_identifier = var.rds_final_snapshot_identifier
  apply_immediately         = false

  tags = local.common_tags
}
