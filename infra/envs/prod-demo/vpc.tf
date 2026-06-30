module "vpc" {
  source = "../../modules/vpc"

  name         = "${local.name_prefix}-vpc"
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr

  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags = local.common_tags
}
