provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_cloudformation_stack" "test" {
  name          = "test-stack2"
  template_body = "${file("${path.module}/template.yml")}"
  capabilities  = ["CAPABILITY_IAM"]

  parameters {
    Name = "amzn-ami-hvm-*"
  }
}

data "aws_cloudformation_stack" "test" {
  name = "test-stack2"
}

output "ami_id" {
  value = "${data.aws_cloudformation_stack.test.outputs["AMIId"]}"
}
