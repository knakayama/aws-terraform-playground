variable "region" {
  default = "ap-northeast-1"
}

variable "kinesis_stream" {
  default = "terraform-kinesis-stream"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_kinesis_stream" "kinesis" {
  name             = "${var.kinesis_stream}"
  shard_count      = 1
  retention_period = 128

  tags {
    Name = "${var.kinesis_stream}"
  }
}

output "kinesis_attributes" {
  value = <<EOT


id: ${aws_kinesis_stream.kinesis.id}
name: ${aws_kinesis_stream.kinesis.name}
shard_count: ${aws_kinesis_stream.kinesis.shard_count}
arn: ${aws_kinesis_stream.kinesis.arn}
EOT
}
