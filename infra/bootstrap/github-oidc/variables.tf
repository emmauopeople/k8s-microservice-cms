variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name."
  type        = string
  default     = "k8s-microservice-cms"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod-demo"
}

variable "github_owner" {
  description = "GitHub repository owner."
  type        = string
  default     = "emmauopeople"
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
  default     = "k8s-microservice-cms"
}

variable "github_actions_role_name" {
  description = "IAM role name for GitHub Actions OIDC."
  type        = string
  default     = "k8s-microservice-cms-github-actions"
}

variable "ecr_repository_names" {
  description = "ECR repositories the GitHub Actions role can push to."
  type        = list(string)

  default = [
    "church-auth-service",
    "church-core-service",
    "church-document-core-service",
    "church-frontend"
  ]
}
