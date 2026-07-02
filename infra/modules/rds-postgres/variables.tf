variable "name" {
  description = "Name prefix for RDS resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be deployed."
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private database subnet IDs for the RDS subnet group."
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to PostgreSQL. Usually private app subnet CIDRs."
  type        = list(string)
}

variable "database_port" {
  description = "PostgreSQL port."
  type        = number
  default     = 5432
}

variable "engine_version" {
  description = "PostgreSQL engine version. Null lets AWS choose the default supported version."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage in GiB for storage autoscaling."
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "RDS storage type."
  type        = string
  default     = "gp3"
}

variable "initial_database_name" {
  description = "Initial database created by RDS. Additional databases are created by migration/init job later."
  type        = string
  default     = "auth_db"
}

variable "additional_database_names" {
  description = "Additional application database names tracked for documentation and later initialization."
  type        = list(string)
  default     = []
}

variable "master_username" {
  description = "Master database username."
  type        = string
  default     = "cms_admin"
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ. False for demo cost control."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection. False for short-lived demo environments."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot during destroy. True for short-lived demo environments."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether database modifications are applied immediately."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
