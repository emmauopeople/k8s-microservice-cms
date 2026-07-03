output "zone_id" {
  description = "Route 53 hosted zone ID."
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "Route 53 hosted zone name."
  value       = aws_route53_zone.this.name
}

output "name_servers" {
  description = "Route 53 name servers to configure as NS records in the parent DNS provider."
  value       = aws_route53_zone.this.name_servers
}

output "certificate_arn" {
  description = "ACM certificate ARN."
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_name" {
  description = "Primary ACM certificate domain name."
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_subject_alternative_names" {
  description = "ACM certificate subject alternative names."
  value       = aws_acm_certificate.this.subject_alternative_names
}

output "certificate_status" {
  description = "ACM certificate status."
  value       = aws_acm_certificate.this.status
}

output "certificate_validation_record_fqdns" {
  description = "DNS validation record FQDNs created in Route 53."
  value       = [for record in aws_route53_record.certificate_validation : record.fqdn]
}

output "certificate_validation_enabled" {
  description = "Whether Terraform waits for ACM certificate validation."
  value       = var.enable_certificate_validation
}
