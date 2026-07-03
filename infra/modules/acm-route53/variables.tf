variable "zone_name" {
  description = "Delegated DNS zone name managed in Route 53."
  type        = string
}

variable "certificate_domain_name" {
  description = "Primary domain name for the ACM certificate."
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names for the ACM certificate."
  type        = list(string)
  default     = []
}

variable "enable_certificate_validation" {
  description = "Whether Terraform should wait for ACM DNS validation. Keep false until parent DNS delegation is configured."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
