output "env_details" {
  value = {
    for k, m in module.static_sites : k => {
      s3_bucket               = m.bucket
      logging_bucket          = m.logging_bucket
      cloudfront_id           = m.cf_distribution_id
      cloudfront_domain       = m.cf_domain_name
      certificate_arn         = m.certificate_arn
      response_headers_id     = m.response_headers_policy_id
      origin_access_control   = m.oac_id
    }
  }
}
