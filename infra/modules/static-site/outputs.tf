output "bucket" {
  value = aws_s3_bucket.site.bucket
}

output "logging_bucket" {
  value = aws_s3_bucket.logs.bucket
}

output "cf_distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "cf_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.cert.certificate_arn
}

output "response_headers_policy_id" {
  value = aws_cloudfront_response_headers_policy.security.id
}

output "oac_id" {
  value = aws_cloudfront_origin_access_control.oac.id
}

output "aliases" {
  value = var.domain_names
}
