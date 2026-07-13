output "bucket_name" {
  description = "Velero S3 backup bucket name."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "Velero S3 backup bucket ARN."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Velero S3 backup bucket regional domain name."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "iam_role_arn" {
  description = "Velero IRSA role ARN."
  value       = aws_iam_role.this.arn
}

output "iam_role_name" {
  description = "Velero IRSA role name."
  value       = aws_iam_role.this.name
}

output "service_account_subject" {
  description = "Kubernetes service account subject trusted by the Velero IAM role."
  value       = local.service_account_sub
}
