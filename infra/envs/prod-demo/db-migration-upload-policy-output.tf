output "db_migration_backup_uploader_policy_arn" {
  description = "IAM policy ARN to attach temporarily to the approved workstation upload identity."
  value       = try(module.db_migration[0].backup_uploader_policy_arn, null)
}
