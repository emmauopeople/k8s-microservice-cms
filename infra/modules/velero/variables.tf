variable "name" {
  description = "Name prefix for Velero resources."
  type        = string
}

variable "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster."
  type        = string
}

variable "oidc_issuer_url" {
  description = "EKS OIDC issuer URL."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Velero."
  type        = string
  default     = "velero"
}

variable "service_account_name" {
  description = "Kubernetes service account name for Velero."
  type        = string
  default     = "velero"
}

variable "bucket_name" {
  description = "Optional explicit S3 bucket name. Leave null to generate a globally unique bucket name."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether Terraform destroy can delete a non-empty Velero bucket. True for short-lived demos, false for production."
  type        = bool
  default     = false
}

variable "backup_expiration_days" {
  description = "Number of days before current Velero backup objects expire."
  type        = number
  default     = 14
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days before noncurrent backup object versions expire."
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
