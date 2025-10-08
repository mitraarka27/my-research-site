terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.53"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_route53_zone" "this" {
  name         = var.route53_zone_name
  private_zone = false
}

module "static_sites" {
  source = "./modules/static-site"
  for_each = var.environments

  env_name            = each.key
  project_name        = var.project_name
  domain_names        = each.value.domain_names
  bucket_name         = each.value.bucket_name
  logging_bucket_name = each.value.logging_bucket_name
  spa_prefixes        = each.value.spa_prefixes
  hosted_zone_id      = data.aws_route53_zone.this.zone_id
}

output "cloudfront_domains" {
  value = {
    for k, m in module.static_sites : k => {
      cf_domain = m.cf_domain_name
      aliases   = m.aliases
    }
  }
}
