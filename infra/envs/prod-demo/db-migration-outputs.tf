output "db_migration_bucket_name" {
  description = "Private encrypted S3 bucket used to stage OVH PostgreSQL backups."
  value       = try(module.db_migration[0].bucket_name, null)
}

output "db_migration_bucket_arn" {
  description = "ARN of the database migration backup bucket."
  value       = try(module.db_migration[0].bucket_arn, null)
}

output "db_migration_kms_key_arn" {
  description = "KMS key ARN used to encrypt migration backups and EC2 storage."
  value       = try(module.db_migration[0].kms_key_arn, null)
}

output "db_migration_instance_id" {
  description = "Temporary migration EC2 instance ID."
  value       = try(module.db_migration[0].instance_id, null)
}

output "db_migration_instance_private_ip" {
  description = "Private IP address of the migration host."
  value       = try(module.db_migration[0].instance_private_ip, null)
}

output "db_migration_instance_role_arn" {
  description = "IAM role ARN assigned to the migration host."
  value       = try(module.db_migration[0].instance_role_arn, null)
}

output "db_migration_s3_vpc_endpoint_id" {
  description = "S3 gateway VPC endpoint used by the private migration host."
  value       = try(module.db_migration[0].s3_vpc_endpoint_id, null)
}

output "db_migration_ssm_start_session_command" {
  description = "Command used to start an SSM Session Manager shell."
  value       = try(module.db_migration[0].ssm_start_session_command, null)
}
