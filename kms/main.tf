variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_kms_key" "a" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "a" {
  name          = "alias/my-key-alias"
  target_key_id = "${aws_kms_key.a.key_id}"
}

output "kms_arn" {
  value = "${aws_kms_key.a.arn}"
}

output "kms_key_id" {
  value = "${aws_kms_key.a.key_id}"
}

output "kms_alias_arn" {
  value = "${aws_kms_alias.a.arn}"
}
