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
  description = "Use one NAT Gateway for demo cost control. Use false for production-style one NAT Gateway per AZ."
  type        = bool
  default     = true
}
