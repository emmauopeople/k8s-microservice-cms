variable "name" {
  description = "Name prefix for database migration resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the private migration host will run."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR used for private DNS egress rules."
  type        = string
}

variable "private_subnet_id" {
  description = "Private application subnet for the migration EC2 instance."
  type        = string
}

variable "private_route_table_ids" {
  description = "Private application route table IDs associated with the S3 gateway endpoint."
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "RDS security group that will accept PostgreSQL from the migration host security group."
  type        = string
}

variable "database_port" {
  description = "PostgreSQL port exposed by RDS."
  type        = number
  default     = 5432
}

variable "create_instance" {
  description = "Create the temporary private EC2 migration host and S3 VPC endpoint. The encrypted bucket remains independent of this setting."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type for the temporary migration host."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Encrypted gp3 root volume size in GiB. It must be large enough to hold the database backup set."
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 20
    error_message = "The migration root volume must be at least 20 GiB."
  }
}

variable "ami_ssm_parameter" {
  description = "SSM public parameter containing the latest Amazon Linux 2023 x86_64 AMI ID."
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "backup_expiration_days" {
  description = "Days to retain current migration backup objects before S3 lifecycle expiration."
  type        = number
  default     = 90
}

variable "noncurrent_version_expiration_days" {
  description = "Days to retain noncurrent backup object versions."
  type        = number
  default     = 30
}

variable "force_destroy" {
  description = "Allow Terraform to delete a non-empty migration bucket. Keep false to protect database backups."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to migration resources."
  type        = map(string)
  default     = {}
}
