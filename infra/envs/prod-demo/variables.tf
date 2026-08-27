variable "aws_region" {
  description = "AWS region for the production demo environment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for AWS resource naming and tagging."
  type        = string
  default     = "k8s-microservice-cms"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod-demo"
}

variable "cluster_name" {
  description = "EKS cluster name planned for this environment."
  type        = string
  default     = "church-prod-demo-eks"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the environment."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.40.0.0/24", "10.40.1.0/24", "10.40.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Private application subnet CIDR blocks for EKS nodes and pods."
  type        = list(string)
  default     = ["10.40.10.0/24", "10.40.11.0/24", "10.40.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "Private database subnet CIDR blocks for RDS."
  type        = list(string)
  default     = ["10.40.20.0/24", "10.40.21.0/24", "10.40.22.0/24"]
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway resources for private app subnet egress."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway for initial cost control. Set false for one NAT Gateway per AZ."
  type        = bool
  default     = true
}

variable "rds_engine_version" {
  description = "Pinned PostgreSQL version for migration compatibility with the current PostgreSQL 16 source."
  type        = string
  default     = "16.14"
}

variable "rds_instance_class" {
  description = "RDS PostgreSQL instance class."
  type        = string
  default     = "db.t4g.small"
}

variable "rds_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum RDS storage in GiB for storage autoscaling."
  type        = number
  default     = 100
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ for RDS. Enable for higher database availability when budget permits."
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "RDS automated backup retention in days."
  type        = number
  default     = 14
}

variable "rds_deletion_protection" {
  description = "Enable RDS deletion protection."
  type        = bool
  default     = true
}

variable "rds_skip_final_snapshot" {
  description = "Skip a final RDS snapshot during destroy. Keep false for live data."
  type        = bool
  default     = false
}

variable "rds_final_snapshot_identifier" {
  description = "Final RDS snapshot identifier used during an intentional destroy."
  type        = string
  default     = "church-prod-demo-postgres-final"
}

variable "document_bucket_force_destroy" {
  description = "Allow Terraform destroy to delete a non-empty document bucket. Keep false for live data."
  type        = bool
  default     = false
}

variable "document_bucket_cors_allowed_origins" {
  description = "Allowed browser origins for S3 document uploads and downloads."
  type        = list(string)
  default = [
    "https://eks.gestionparoissiale.org",
    "http://localhost:3000",
    "http://localhost:5173"
  ]
}

variable "dns_zone_name" {
  description = "Delegated Route 53 hosted zone name for the EKS environment."
  type        = string
  default     = "eks.gestionparoissiale.org"
}

variable "acm_certificate_domain_name" {
  description = "Primary ACM certificate domain name."
  type        = string
  default     = "eks.gestionparoissiale.org"
}

variable "acm_subject_alternative_names" {
  description = "ACM certificate subject alternative names."
  type        = list(string)
  default     = ["*.eks.gestionparoissiale.org"]
}

variable "enable_acm_certificate_validation" {
  description = "Set true only after Namecheap delegates eks.gestionparoissiale.org to the Route 53 name servers."
  type        = bool
  default     = false
}

variable "waf_rate_limit" {
  description = "Maximum requests from a single IP address during a five-minute window."
  type        = number
  default     = 2000
}

variable "eks_kubernetes_version" {
  description = "Pinned Kubernetes minor version for the EKS cluster."
  type        = string
  default     = "1.36"
}

variable "eks_endpoint_public_access" {
  description = "Enable public access to the EKS API endpoint."
  type        = bool
  default     = true
}

variable "eks_endpoint_private_access" {
  description = "Enable private access to the EKS API endpoint."
  type        = bool
  default     = true
}

variable "eks_public_access_cidrs" {
  description = "Administrative CIDR blocks allowed to access the public EKS API endpoint. Supply your current public IP as /32."
  type        = list(string)

  validation {
    condition     = length(var.eks_public_access_cidrs) > 0 && !contains(var.eks_public_access_cidrs, "0.0.0.0/0")
    error_message = "eks_public_access_cidrs must contain at least one restricted CIDR and must not include 0.0.0.0/0."
  }
}

variable "eks_node_instance_types" {
  description = "Instance types for the EKS managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_capacity_type" {
  description = "Capacity type for EKS managed nodes."
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 5
}

variable "eks_node_disk_size" {
  description = "EKS worker node root disk size in GiB."
  type        = number
  default     = 30
}
