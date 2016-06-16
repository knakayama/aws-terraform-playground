provider "aws" {
  region = "${var.region}"
}

resource "aws_cloudformation_stack" "vpc" {
  name          = "vpc-stack"
  template_body = "${file("templates/vpc.template")}"
}
