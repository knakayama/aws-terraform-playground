# ref: https://github.com/matsuu/terraform-pixiv-isucon2016

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "default" {
  key_name   = "default"
  public_key = "${file(var.public_key)}"
}

resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "${var.name_prefix}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.name_prefix}"
  }
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, 8, 1)}"
  availability_zone       = "${format("%s%s", var.region, var.az)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name_prefix}"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "${var.access_cidr_blocks}"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "${var.name_prefix}"
  }
}

resource "aws_route_table_association" "default" {
  subnet_id      = "${aws_subnet.default.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_security_group" "default" {
  vpc_id      = "${aws_vpc.default.id}"
  name_prefix = "${var.name_prefix}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.access_cidr_blocks}"]
    self        = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.access_cidr_blocks}"]
    self        = true
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name_prefix}"
  }
}

resource "aws_spot_instance_request" "web" {
  spot_price                  = "${var.spot_prices.web}"
  wait_for_fulfillment        = "${var.wait_for_fulfillment}"
  ami                         = "${var.amis.web}"
  instance_type               = "${var.instance_types.web}"
  key_name                    = "${aws_key_pair.default.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.default.id}"]
  subnet_id                   = "${aws_subnet.default.id}"
  associate_public_ip_address = true
  user_data                   = "${file("cloud-config.yml")}"

  tags {
    Name = "${var.name_prefix}-web"
  }
}
