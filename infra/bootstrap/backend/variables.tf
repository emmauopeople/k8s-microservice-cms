variable "aws_region" {
  description = "AWS region where the Terraform backend resources will be created."
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
}
