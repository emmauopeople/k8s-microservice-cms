output "db_instance_id" {
  description = "RDS DB instance ID."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS DB instance ARN."
  value       = aws_db_instance.this.arn
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "RDS PostgreSQL address."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS PostgreSQL port."
  value       = aws_db_instance.this.port
}

output "db_subnet_group_name" {
  description = "RDS DB subnet group name."
  value       = aws_db_subnet_group.this.name
}

output "db_security_group_id" {
  description = "RDS security group ID."
  value       = aws_security_group.this.id
}

output "initial_database_name" {
  description = "Initial database created by RDS."
  value       = var.initial_database_name
}

output "application_database_names" {
  description = "Application database names expected by the platform."
  value       = concat([var.initial_database_name], var.additional_database_names)
}

output "master_user_secret_arn" {
  description = "AWS-managed Secrets Manager secret ARN for the RDS master user."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
  sensitive   = true
}
