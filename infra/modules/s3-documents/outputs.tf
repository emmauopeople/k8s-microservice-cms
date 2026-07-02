output "bucket_name" {
  description = "S3 document bucket name."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_id" {
  description = "S3 document bucket ID."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "S3 document bucket ARN."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "S3 document bucket regional domain name."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_cors_enabled" {
  description = "Whether CORS is configured for the document bucket."
  value       = length(var.cors_allowed_origins) > 0
}
