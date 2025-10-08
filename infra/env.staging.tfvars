project_name       = "my-research-site"
aws_account_id     = "370437978362"
route53_zone_name  = "arka-mitra-research.com."

environments = {
  staging = {
    domain_names        = ["staging.arka-mitra-research.com"]
    bucket_name         = "arka-mitra-research-com-site-staging"
    logging_bucket_name = "arka-mitra-research-com-cf-logs-staging"
    spa_prefixes        = [] # add prefixes if you want SPA fallback only for certain paths
  }
}
