variable "name" {}

variable "vpc_cidr" {}

variable "email_address" {}

variable "instance_types" {
  type = "map"
}

variable "asg_config" {
  type = "map"
}

variable "db_config" {
  type = "map"
}

variable "domain_config" {
  type = "map"
}

variable "cf_config" {
  type = "map"
}

variable "elasticache_config" {
  type = "map"
}

variable "azs" {
  type = "list"
}

variable "amazon_linux_id" {}

variable "instance_profile_id" {}
