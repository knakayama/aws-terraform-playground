variable "env" {}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_eip" "lb" {
  count = "${var.env == "prd" ? 1 : 0 }"
  vpc   = true
}
