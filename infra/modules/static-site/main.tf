locals {
  common_tags = {
    Project = var.project_name
    Env     = var.env_name
  }

  robots_txt = var.env_name == "staging" ? "User-agent: *\nDisallow: /\n" : "User-agent: *\nAllow: /\n"

  content_security_policy = "default-src 'self'; img-src 'self' data: blob:; script-src 'self'; style-src 'self' 'unsafe-inline'; font-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'"

  has_spa = length(var.spa_prefixes) > 0
}

# --- Logging bucket (for CloudFront) ---
resource "aws_s3_bucket" "logs" {
  bucket        = var.logging_bucket_name
  force_destroy = true
  tags          = local.common_tags
}

# Enable ACLs so CloudFront can write standard logs
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  bucket     = aws_s3_bucket.logs.id
  acl        = "log-delivery-write"
  depends_on = [aws_s3_bucket_ownership_controls.logs]
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }
}

# --- Site bucket (private) ---
resource "aws_s3_bucket" "site" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = local.common_tags
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "robots" {
  bucket       = aws_s3_bucket.site.bucket
  key          = "robots.txt"
  content      = local.robots_txt
  content_type = "text/plain"
  acl          = "private"
}

# --- ACM certificate (DNS-validated) ---
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_names[0]
  subject_alternative_names = slice(var.domain_names, 1, length(var.domain_names))
  validation_method         = "DNS"
  tags                      = local.common_tags
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# --- CloudFront OAC ---
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project_name}-${var.env_name}-oac"
  description                       = "OAC for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- Response Headers Policy (security) ---
resource "aws_cloudfront_response_headers_policy" "security" {
  name = "${var.project_name}-${var.env_name}-security-headers"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "no-referrer-when-downgrade"
      override        = true
    }

    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }

    content_security_policy {
      content_security_policy = local.content_security_policy
      override                = true
    }
  }

  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "geolocation=(), microphone=(), camera=(), fullscreen=(self)"
      override = true
    }
  }
}

# --- Cache Policies ---
resource "aws_cloudfront_cache_policy" "html" {
  name = "${var.project_name}-${var.env_name}-html"

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }

  default_ttl = 60
  min_ttl     = 0
  max_ttl     = 300
}

resource "aws_cloudfront_cache_policy" "assets" {
  name = "${var.project_name}-${var.env_name}-assets"

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }

  default_ttl = 31536000
  min_ttl     = 0
  max_ttl     = 31536000
}

resource "aws_cloudfront_function" "uri_normalize" {
  name    = "${var.project_name}-${var.env_name}-uri-normalize"
  runtime = "cloudfront-js-1.0"
  comment = "Map pretty URLs and extensionless paths to index.html"
  publish = true
  code    = <<-JS
function handler(event) {
  var req = event.request;
  var uri = req.uri;

  // if ends with "/", append index.html
  if (uri.endsWith("/")) {
    req.uri = uri + "index.html";
    return req;
  }

  // if no file extension and not root, append "/index.html"
  if (!uri.includes(".") && uri !== "/index.html" && uri !== "/") {
    req.uri = uri + "/index.html";
    return req;
  }

  return req;
}
JS
}

# --- CloudFront Distribution ---
data "aws_s3_bucket" "site" {
  bucket = aws_s3_bucket.site.bucket
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project_name}-${var.env_name}"

  default_root_object = "index.html"
  aliases             = var.domain_names

  origin {
    domain_name              = data.aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id           = "s3-${var.bucket_name}"
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = aws_cloudfront_cache_policy.html.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id
    compress                   = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.uri_normalize.arn
    }
  }

  ordered_cache_behavior {
    path_pattern               = "assets/*"
    target_origin_id           = "s3-${var.bucket_name}"
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = aws_cloudfront_cache_policy.assets.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id
    compress                   = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    # No function association for static assets
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.has_spa ? var.spa_prefixes : []

    content {
      path_pattern               = "${ordered_cache_behavior.value}*"
      target_origin_id           = "s3-${var.bucket_name}"
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = aws_cloudfront_cache_policy.html.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id
      compress                   = true

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]

      function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.uri_normalize.arn
    }
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  # Map S3 403 (private bucket missing key) to site 404
  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  logging_config {
    bucket          = "${aws_s3_bucket.logs.bucket}.s3.amazonaws.com"
    prefix          = "${var.env_name}/"
    include_cookies = false
  }

  tags = local.common_tags
}

# --- S3 bucket policy for OAC (only allow this distribution) ---
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid      = "AllowCloudFrontOAC",
      Effect   = "Allow",
      Principal = {
        Service = "cloudfront.amazonaws.com"
      },
      Action   = ["s3:GetObject"],
      Resource = "${aws_s3_bucket.site.arn}/*",
      Condition = {
        StringEquals = {
          "AWS:SourceArn" : aws_cloudfront_distribution.this.arn
        }
      }
    }]
  })
}

# --- Route 53 ALIAS records ---
resource "aws_route53_record" "aliases" {
  for_each = toset(var.domain_names)

  zone_id = var.hosted_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aliases_aaaa" {
  for_each = toset(var.domain_names)

  zone_id = var.hosted_zone_id
  name    = each.value
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
