module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.eks_kubernetes_version

  cluster_subnet_ids = module.vpc.private_app_subnet_ids
  node_subnet_ids    = module.vpc.private_app_subnet_ids

  endpoint_private_access = var.eks_endpoint_private_access
  endpoint_public_access  = var.eks_endpoint_public_access
  public_access_cidrs     = var.eks_public_access_cidrs

  enabled_cluster_log_types  = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_log_retention_days = 7

  node_group_name     = "system"
  node_instance_types = var.eks_node_instance_types
  node_capacity_type  = var.eks_node_capacity_type
  node_desired_size   = var.eks_node_desired_size
  node_min_size       = var.eks_node_min_size
  node_max_size       = var.eks_node_max_size
  node_disk_size      = var.eks_node_disk_size

  cluster_addons = ["vpc-cni", "kube-proxy", "coredns"]
  cluster_addon_configuration_values = {
    vpc-cni = jsonencode({
      enableNetworkPolicy = "true"
    })
  }

  tags = local.common_tags
}
