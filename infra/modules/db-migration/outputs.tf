output "bucket_name" {
  description = "Private encrypted S3 bucket used to stage OVH PostgreSQL backups."
  value       = aws_s3_bucket.migration.id
}

output "bucket_arn" {
  description = "ARN of the migration backup bucket."
  value       = aws_s3_bucket.migration.arn
}

output "kms_key_arn" {
  description = "KMS key ARN used for the migration bucket and EC2 root volume."
  value       = aws_kms_key.migration.arn
}

output "instance_id" {
  description = "Temporary migration EC2 instance ID, or null when create_instance is false."
  value       = try(aws_instance.migration[0].id, null)
}

output "instance_private_ip" {
  description = "Private IP of the migration host, or null when create_instance is false."
  value       = try(aws_instance.migration[0].private_ip, null)
}

output "instance_security_group_id" {
  description = "Migration host security group ID, or null when create_instance is false."
  value       = try(aws_security_group.instance[0].id, null)
}

output "instance_role_arn" {
  description = "IAM role ARN used by the migration host, or null when create_instance is false."
  value       = try(aws_iam_role.instance[0].arn, null)
}

output "s3_vpc_endpoint_id" {
  description = "S3 gateway VPC endpoint ID, or null when create_instance is false."
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "ssm_start_session_command" {
  description = "AWS CLI command used to start a Session Manager shell on the migration host."
  value       = try("aws ssm start-session --target ${aws_instance.migration[0].id}", null)
}
