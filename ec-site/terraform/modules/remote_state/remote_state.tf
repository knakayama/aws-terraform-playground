variable "region" {}

variable "remote_state_bucket" {}

resource "aws_s3_bucket" "remote_state" {
  bucket        = "${var.remote_state_bucket}"
  acl           = "private"
  force_destroy = true
}

resource "terraform_remote_state" "remote_state" {
  backend = "s3"

  config {
    bucket = "${aws_s3_bucket.remote_state.bucket}"
    key    = "terraform.tfstate"
    region = "${var.region}"
  }
}

output "remote_state_bucket" {
  value = "${aws_s3_bucket.remote_state.bucket}"
}
