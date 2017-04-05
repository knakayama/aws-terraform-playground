variable "name" {
  default = "proxy-protocol"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_id" {}
variable "acm_domain" {}

variable "subnet_ids" {
  default = {
    ghe_primary   = ""
    ghe_secondary = ""
  }
}
