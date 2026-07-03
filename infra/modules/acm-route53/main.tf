locals {
  common_tags = merge(var.tags, { Module = "acm-route53" })
}

resource "aws_route53_zone" "this" {
  name    = var.zone_name
  comment = "Delegated hosted zone for ${var.zone_name}"

  tags = merge(local.common_tags, {
    Name = var.zone_name
  })
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.certificate_domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = var.certificate_domain_name
  })
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.this.domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  count = var.enable_certificate_validation ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}
