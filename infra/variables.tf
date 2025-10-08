variable "project_name" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "route53_zone_name" {
  type = string
  # e.g., "example.com."
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environments" {
  description = "Map of env configs"
  type = map(object({
    domain_names        = list(string)
    bucket_name         = string
    logging_bucket_name = string
    spa_prefixes        = list(string)
  }))
}
