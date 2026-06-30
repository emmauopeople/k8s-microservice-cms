locals {
  name_prefix = "church-prod-demo"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Workload    = "parish-management-system"
  }
}
