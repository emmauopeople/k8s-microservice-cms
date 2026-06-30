output "repository_names" {
  description = "Created ECR repository names."
  value       = [for repo in aws_ecr_repository.this : repo.name]
}

output "repository_urls" {
  description = "Created ECR repository URLs."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "repository_arns" {
  description = "Created ECR repository ARNs."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}
