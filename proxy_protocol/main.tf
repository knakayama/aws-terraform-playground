variable "name" {
  default = "test"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "azs" {
  default = "ap-northeast-1a"
}

variable "public_subnets" {
  default = "172.16.0.0/24"
}

variable "web_instance_type" {
  default = "t2.nano"
}

variable "web_instance_ami_id" {
  default = "ami-383c1956"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file("site_key.pub")}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_subnet" "public" {
  count             = 1
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = 1
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.public.*.id}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_security_group" "elb" {
  name        = "${var.name}-elb"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name}-ELB-SG"

  ingress {
    from_port   = 8888
    to_port     = 8888
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

resource "aws_security_group" "web" {
  name        = "${var.name}-web"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name}-Web-SG"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8888
    to_port         = 8888
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  count                       = 1
  ami                         = "${var.web_instance_ami_id}"
  instance_type               = "${var.web_instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.web.*.id}"]
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  key_name                    = "${aws_key_pair.site_key.key_name}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  user_data = <<EOT
#cloud-config
repo_update: true
repo_upgrade: all
timezone: "Asia/Tokyo"
EOT
}

resource "aws_elb" "elb" {
  name                        = "${var.name}-elb"
  subnets                     = ["${aws_subnet.public.*.id}"]
  security_groups             = ["${aws_security_group.elb.id}"]
  instances                   = ["${aws_instance.web.*.id}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  idle_timeout                = 60

  listener {
    lb_port           = 8888
    lb_protocol       = "tcp"
    instance_port     = 8888
    instance_protocol = "tcp"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:8888"
    interval            = 30
  }
}

resource "aws_proxy_protocol_policy" "elb" {
  load_balancer  = "${aws_elb.elb.name}"
  instance_ports = [8888]
}

output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

output "web_public_ip" {
  value = "${aws_instance.web.public_ip}"
}
