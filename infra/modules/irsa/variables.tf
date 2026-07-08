variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "oidc_issuer_url" {
  description = "EKS OIDC issuer URL."
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID used by ExternalDNS."
  type        = string
}

variable "document_bucket_arn" {
  description = "S3 document bucket ARN used by the document service."
  type        = string
}

variable "secrets_manager_secret_arns" {
  description = "Secrets Manager secret ARNs that application workloads may read."
  type        = list(string)
  default     = []
  sensitive   = true
}

variable "aws_load_balancer_controller_namespace" {
  description = "Namespace for the AWS Load Balancer Controller service account."
  type        = string
  default     = "kube-system"
}

variable "aws_load_balancer_controller_service_account" {
  description = "Service account name for AWS Load Balancer Controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "external_dns_namespace" {
  description = "Namespace for the ExternalDNS service account."
  type        = string
  default     = "external-dns"
}

variable "external_dns_service_account" {
  description = "Service account name for ExternalDNS."
  type        = string
  default     = "external-dns"
}

variable "ebs_csi_namespace" {
  description = "Namespace for the EBS CSI controller service account."
  type        = string
  default     = "kube-system"
}

variable "ebs_csi_service_account" {
  description = "Service account name for the EBS CSI controller."
  type        = string
  default     = "ebs-csi-controller-sa"
}

variable "document_service_namespace" {
  description = "Namespace for the document service workload."
  type        = string
  default     = "church-prod"
}

variable "document_service_account" {
  description = "Service account name for the document service workload."
  type        = string
  default     = "document-service"
}

variable "app_secrets_namespace" {
  description = "Namespace for application workloads that read Secrets Manager secrets."
  type        = string
  default     = "church-prod"
}

variable "app_secrets_service_accounts" {
  description = "Application service accounts allowed to read configured Secrets Manager secrets."
  type        = list(string)
  default     = ["auth-service", "church-core-service", "document-service"]
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
