
output "ecr_repository_names" {
  description = "ECR repository names."
  value       = module.ecr.repository_names
}

output "ecr_repository_urls" {
  description = "ECR repository URLs."
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ECR repository ARNs."
  value       = module.ecr.repository_arns
}
