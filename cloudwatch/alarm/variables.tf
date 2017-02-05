variable "region" {
  default = "ap-northeast-1"
}

variable "sns_topic" {
  default = "test"
}

variable "policy_name" {
  default = "test"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  current = true
}
