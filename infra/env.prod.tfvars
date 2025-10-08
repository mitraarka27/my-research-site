project_name       = "my-research-site"
aws_account_id     = "370437978362"
route53_zone_name  = "arka-mitra-research.com."

environments = {
  prod = {
    domain_names        = ["arka-mitra-research.com", "www.arka-mitra-research.com"]
    bucket_name         = "arka-mitra-research-com-site-prod"
    logging_bucket_name = "arka-mitra-research-com-cf-logs-prod"
    spa_prefixes        = [] # add prefixes if you want SPA fallback only for certain paths
  }
}
