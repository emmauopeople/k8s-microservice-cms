output "github_actions_role_name" {
  description = "IAM role name for GitHub Actions."
  value       = aws_iam_role.github_actions.name
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC."
  value       = aws_iam_role.github_actions.arn
}

output "allowed_github_subjects" {
  description = "GitHub OIDC subject claims allowed to assume this role."
  value       = local.allowed_subjects
}

output "allowed_ecr_repository_arns" {
  description = "ECR repository ARNs the role can push to."
  value       = local.ecr_repository_arns
}
