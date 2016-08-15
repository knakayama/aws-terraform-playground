variable "region" {
  default = "ap-northeast-1"
}

variable "aws_services" {
  default = [
    "cloudfront",
    "ec2",
    "route53",
    "route53_healthchecks",
  ]
}
