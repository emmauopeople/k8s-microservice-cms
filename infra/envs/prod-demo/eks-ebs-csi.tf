resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.irsa.ebs_csi_role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ebs-csi-addon"
  })

  depends_on = [
    module.eks,
    module.irsa
  ]
}
