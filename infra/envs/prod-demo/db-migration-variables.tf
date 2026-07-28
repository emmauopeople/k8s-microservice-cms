variable "enable_db_migration_storage" {
  description = "Create the private encrypted S3 bucket used to stage OVH PostgreSQL backups."
  type        = bool
  default     = false
}

variable "enable_db_migration_host" {
  description = "Create the temporary SSM-managed EC2 migration host. Requires enable_db_migration_storage=true."
  type        = bool
  default     = false
}

variable "db_migration_instance_type" {
  description = "EC2 instance type for the temporary database migration host."
  type        = string
  default     = "t3.micro"
}

variable "db_migration_root_volume_size" {
  description = "Encrypted migration-host root volume size in GiB. Increase when the document database backup is large."
  type        = number
  default     = 30
}

variable "db_migration_backup_expiration_days" {
  description = "Number of days to retain current migration backup objects in S3."
  type        = number
  default     = 90
}

variable "db_migration_noncurrent_expiration_days" {
  description = "Number of days to retain noncurrent S3 object versions."
  type        = number
  default     = 30
}

variable "db_migration_bucket_force_destroy" {
  description = "Allow Terraform to delete a non-empty migration bucket. Keep false to protect backups."
  type        = bool
  default     = false
}
