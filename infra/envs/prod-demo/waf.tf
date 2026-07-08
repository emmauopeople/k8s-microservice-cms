module "waf" {
  source = "../../modules/waf"

  name       = "${local.name_prefix}-waf"
  scope      = "REGIONAL"
  rate_limit = var.waf_rate_limit

  enable_rate_limit_rule           = true
  enable_common_rule_set           = true
  enable_known_bad_inputs_rule_set = true
  enable_sql_injection_rule_set    = true
  enable_ip_reputation_rule_set    = true

  cloudwatch_metrics_enabled = true
  sampled_requests_enabled   = true

  tags = local.common_tags
}
