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

variable "github_actions_role_name" {
  description = "IAM role name for GitHub Actions OIDC."
  type        = string
  default     = "k8s-microservice-cms-github-actions"
}

variable "github_repositories" {
  description = "GitHub repositories allowed to assume this IAM role through OIDC."
  type        = list(string)

  default = [
    "emmauopeople/k8s-microservice-cms",
    "emmauopeople/church_app"
  ]
}

variable "allowed_branch_patterns" {
  description = "Branch patterns allowed to assume the GitHub Actions IAM role."
  type        = list(string)

  default = [
    "main",
    "feature/*",
    "release/*"
  ]
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
