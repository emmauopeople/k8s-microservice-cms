output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role ARN for AWS Load Balancer Controller."
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "aws_load_balancer_controller_service_account" {
  description = "Service account subject for AWS Load Balancer Controller."
  value       = local.aws_load_balancer_controller_subject
}

output "external_dns_role_arn" {
  description = "IRSA role ARN for ExternalDNS."
  value       = aws_iam_role.external_dns.arn
}

output "external_dns_service_account" {
  description = "Service account subject for ExternalDNS."
  value       = local.external_dns_subject
}

output "ebs_csi_role_arn" {
  description = "IRSA role ARN for the EBS CSI controller."
  value       = aws_iam_role.ebs_csi.arn
}

output "ebs_csi_service_account" {
  description = "Service account subject for the EBS CSI controller."
  value       = local.ebs_csi_subject
}

output "document_service_s3_role_arn" {
  description = "IRSA role ARN for document-service S3 access."
  value       = aws_iam_role.document_service_s3.arn
}

output "document_service_s3_service_account" {
  description = "Service account subject for document-service S3 access."
  value       = local.document_service_subject
}

output "app_secrets_reader_role_arn" {
  description = "IRSA role ARN for application Secrets Manager access."
  value       = aws_iam_role.app_secrets_reader.arn
}

output "app_secrets_reader_service_accounts" {
  description = "Service account subjects allowed to read configured Secrets Manager secrets."
  value       = local.app_secrets_subjects
}
