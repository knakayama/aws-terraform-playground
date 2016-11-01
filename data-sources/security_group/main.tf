provider "aws" {
  region = "ap-northeast-1"
}

data "aws_security_group" "by_tags" {
  tags {
    Name = "test"
  }
}

output "security_group_id" {
  value = "${data.aws_security_group.by_tags.id}"
}

output "security_group_name" {
  value = "${data.aws_security_group.by_tags.name}"
}

output "security_group_tags" {
  value = "${data.aws_security_group.by_tags.tags}"
}

output "security_group_vpc_id" {
  value = "${data.aws_security_group.by_tags.vpc_id}"
}
