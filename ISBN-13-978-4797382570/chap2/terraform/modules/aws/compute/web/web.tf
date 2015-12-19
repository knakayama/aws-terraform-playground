variable "name"               { default = "web" }
variable "vpc_id"             { }
variable "key_name"           { }
variable "azs"                { }
variable "public_subnet_ids"  { }
variable "instance_type"      { }
variable "instance_ami_id"    { }

resource "aws_security_group" "web" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Web security group"

  tags { Name = "${var.name}" }

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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  # FIXME: Cycle error
  # * Cycle: module.compute.module.web.aws_instance.web (destroy), module.compute.module.web.var.public_subnet_ids, module.network.module.public_subnet.output.subnet_ids, module.network.output.public_subnet_ids, module.compute.var.public_subnet_ids, module.compute.module.web.aws_eip.web (destroy), module.network.module.public_subnet.aws_subnet.public (destroy), module.network.module.public_subnet.aws_subnet.public
  #count                       = "${length(split(",", var.public_subnet_ids))}"
  count                       = "${length(split(",", var.azs))}"
  ami                         = "${var.instance_ami_id}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${element(split(",", var.public_subnet_ids), count.index)}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = false

  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }

  user_data = <<EOT
#!/bin/bash

yum update -y
yum install httpd -y
service httpd start
uname -n > /var/www/html/index.html
EOT

  tags { Name = "${var.name}.${count.index+1}" }
}

resource "aws_eip" "web" {
  #count    = "${length(split(",", var.public_subnet_ids))}"
  count    = "${length(split(",", var.azs))}"
  instance = "${element(aws_instance.web.*.id, count.index)}"
  vpc      = true
}

output public_ips   { value = "${join(",", aws_eip.web.*.public_ip)}" }
output instance_ids { value = "${join(",", aws_instance.web.*.id)}" }
