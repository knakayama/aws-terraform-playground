variable "name"              { default = "web" }
variable "vpc_ids"           { }
variable "key_name"          { }
variable "public_subnet_ids" { }
variable "azs"               { }
variable "instance_type"     { }
variable "instance_ami_id"   { }

resource "aws_security_group" "web" {
  count       = "${length(split(",", var.azs))}"
  name        = "${var.name}"
  vpc_id      = "${element(split(",", var.vpc_ids), count.index)}"
  description = "Web SG ${element(split(",", var.vpc_ids), count.index)}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags { Name = "${var.name}.${element(split(",", var.vpc_ids), count.index)}" }
}

resource "aws_instance" "web" {
  count                  = "${length(split(",", var.azs))}"
  ami                    = "${var.instance_ami_id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${element(aws_security_group.web.*.id, count.index)}"]
  subnet_id              = "${element(split(",", var.public_subnet_ids), count.index)}"
  key_name               = "${var.key_name}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  user_data = <<EOT
#!/bin/bash

yum update -y
yum install httpd -y
service httpd start
EOT

  tags { Name = "${var.name}.${element(split(",", var.vpc_ids), count.index)}" }
}

output "public_ips"  { value = "${join(",", aws_instance.web.*.public_ip)}" }
output "private_ips" { value = "${join(",", aws_instance.web.*.private_ip)}" }
