variable "name" {
  description = "Name prefix for the S3 document bucket."
  type        = string
}

variable "bucket_name" {
  description = "Optional explicit S3 bucket name. Leave null to generate a globally unique name."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether to allow Terraform destroy to delete a non-empty bucket. True for short-lived demos, false for production."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Whether to enable S3 bucket versioning."
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "Allowed origins for browser uploads/downloads using pre-signed URLs."
  type        = list(string)
  default     = []
}

variable "cors_allowed_methods" {
  description = "Allowed CORS methods for the document bucket."
  type        = list(string)
  default     = ["GET", "HEAD", "PUT", "POST"]
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days before noncurrent object versions expire."
  type        = number
  default     = 30
}

variable "abort_incomplete_multipart_upload_days" {
  description = "Number of days before incomplete multipart uploads are aborted."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
