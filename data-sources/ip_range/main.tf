provider "aws" {
  region = "${var.region}"
}

data "aws_ip_ranges" "ap_northeast_1" {
  regions  = ["${var.region}"]
  services = ["route53_healthchecks"]
}
