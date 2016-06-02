variable "name" {
  default = "codedeploy-simple"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "az" {
  default = "ap-northeast-1a"
}

variable "public_subnet" {
  default = "172.16.0.0/24"
}

variable "web_instance_type" {
  default = "t2.micro"
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
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.public_subnet}"
  availability_zone       = "${var.az}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.public.id}"]

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

resource "aws_security_group" "web" {
  name        = "${var.name}-web"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name}-SG"

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
    from_port   = 443
    to_port     = 443
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

resource "aws_iam_role" "web" {
  name               = "${var.name}"
  assume_role_policy = "${file(concat(path.module, "/", "assume_role_policy.json"))}"
}

resource "aws_iam_instance_profile" "web" {
  name  = "${var.name}"
  roles = ["${aws_iam_role.web.name}"]
}

resource "aws_iam_policy_attachment" "web" {
  name       = "${var.name}"
  roles      = ["${aws_iam_role.web.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_instance" "web" {
  ami                         = "${var.web_instance_ami_id}"
  instance_type               = "${var.web_instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${aws_subnet.public.id}"
  key_name                    = "${aws_key_pair.site_key.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.web.id}"
  user_data                   = "${file(concat(path.module, "/cloud_config.yml"))}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    "Role" = "web"
    "Env"  = "dev"
  }
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name}"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "codedeploy" {
  name = "codedeploy"

  assume_role_policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOT
}

resource "aws_iam_role_policy" "codedeploy" {
  name = "web-policy"
  role = "${aws_iam_role.codedeploy.id}"

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "tag:GetTags",
                "tag:GetResources"
            ],
            "Resource": "*"
        }
    ]
}
EOT
}

resource "aws_codedeploy_app" "web" {
  name = "sample-app"
}

resource "aws_codedeploy_deployment_group" "web" {
  app_name              = "${aws_codedeploy_app.web.name}"
  deployment_group_name = "sample-group"
  service_role_arn      = "${aws_iam_role.codedeploy.arn}"

  ec2_tag_filter {
    key   = "Role"
    type  = "KEY_AND_VALUE"
    value = "web"
  }
}

output "web_public_ip" {
  value = "${aws_instance.web.public_ip}"
}

output "s3_bucket" {
  value = "${aws_s3_bucket.s3.bucket}"
}
