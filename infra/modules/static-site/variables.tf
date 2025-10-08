variable "env_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "domain_names" {
  type = list(string)
}

variable "bucket_name" {
  type = string
}

variable "logging_bucket_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "spa_prefixes" {
  type = list(string)
}
