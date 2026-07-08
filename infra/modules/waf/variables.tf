variable "name" {
  description = "Name for the WAF web ACL."
  type        = string
}

variable "scope" {
  description = "WAF scope. Use REGIONAL for ALB and CLOUDFRONT for CloudFront."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "scope must be REGIONAL or CLOUDFRONT."
  }
}

variable "rate_limit" {
  description = "Maximum requests allowed from one IP address during a five-minute window."
  type        = number
  default     = 2000
}

variable "enable_rate_limit_rule" {
  description = "Whether to enable the IP-based rate limit rule."
  type        = bool
  default     = true
}

variable "enable_common_rule_set" {
  description = "Whether to enable AWS managed common rule set."
  type        = bool
  default     = true
}

variable "enable_known_bad_inputs_rule_set" {
  description = "Whether to enable AWS managed known bad inputs rule set."
  type        = bool
  default     = true
}

variable "enable_sql_injection_rule_set" {
  description = "Whether to enable AWS managed SQL injection rule set."
  type        = bool
  default     = true
}

variable "enable_ip_reputation_rule_set" {
  description = "Whether to enable AWS managed Amazon IP reputation rule set."
  type        = bool
  default     = true
}

variable "cloudwatch_metrics_enabled" {
  description = "Whether to enable CloudWatch metrics for the WAF web ACL."
  type        = bool
  default     = true
}

variable "sampled_requests_enabled" {
  description = "Whether to enable sampled request visibility."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
