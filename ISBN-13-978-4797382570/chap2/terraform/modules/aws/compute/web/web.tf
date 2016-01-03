variable "name"               { default = "web" }
variable "vpc_id"             { }
variable "key_name"           { }
variable "azs"                { }
variable "public_subnet_ids"  { }
variable "instance_type"      { }
variable "instance_ami_id"    { }

resource "aws_security_group" "elb" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "ELB security group"

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

  tags { Name = "${var.name}" }
}

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
  count    = "${length(split(",", var.azs))}"
  instance = "${element(aws_instance.web.*.id, count.index)}"
  vpc      = true
}

resource "aws_elb" "elb" {
  name                        = "${var.name}"
  subnets                     = ["${split(",", var.public_subnet_ids)}"]
  instances                   = ["${aws_instance.web.*.id}"]
  security_groups             = ["${aws_security_group.elb.id}"]
  connection_draining         = true
  connection_draining_timeout = 300
  cross_zone_load_balancing   = true

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  tags { Name = "${var.name}" }
}

output "web_public_ips" { value = "${join(",", aws_eip.web.*.public_ip)}" }
output "elb_dns_name"   { value = "${aws_elb.elb.dns_name}" }
