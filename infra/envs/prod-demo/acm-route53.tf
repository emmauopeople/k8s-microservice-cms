module "acm_route53" {
  source = "../../modules/acm-route53"

  zone_name                 = var.dns_zone_name
  certificate_domain_name   = var.acm_certificate_domain_name
  subject_alternative_names = var.acm_subject_alternative_names

  enable_certificate_validation = var.enable_acm_certificate_validation

  tags = local.common_tags
}
