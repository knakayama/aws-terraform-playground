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

resource "aws_launch_configuration" "as_conf" {
  name_prefix                 = "${var.name_prefix}-"
  image_id                    = "${var.amis.web}"
  instance_type               = "${var.instance_types.web}"
  spot_price                  = "${var.spot_prices.web}"
  key_name                    = "${aws_key_pair.default.key_name}"
  security_groups             = ["${aws_security_group.default.id}"]
  user_data                   = "${file("cloud-config.yml")}"
  associate_public_ip_address = true
  enable_monitoring           = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.name_prefix}"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  vpc_zone_identifier  = ["${aws_subnet.default.id}"]
  desired_capacity     = "${var.desired_capacity}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  force_delete         = true

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}"
    propagate_at_launch = true
  }
}
