output "backup_uploader_policy_arn" {
  description = "Managed IAM policy ARN to attach temporarily to the approved workstation upload principal."
  value       = aws_iam_policy.backup_uploader.arn
}
