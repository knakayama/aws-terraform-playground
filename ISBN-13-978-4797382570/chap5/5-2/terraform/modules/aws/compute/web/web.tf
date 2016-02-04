variable "name"             { default = "web" }
variable "region"           { }
variable "vpc_id"           { }
variable "key_name"         { }
variable "public_subnet_id" { }
variable "instance_type"    { }
variable "instance_ami_id"  { }
variable "sns_topic_arn"    { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "web" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Web SG"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags { Name = "${var.name}-web" }
}

resource "aws_iam_role" "web" {
  name = "${var.name}"
  assume_role_policy = "${file(concat(path.module, "/", "assume_role_policy.json"))}"
}

resource "aws_iam_instance_profile" "web" {
  name  = "${var.name}"
  roles = ["${aws_iam_role.web.name}"]
}

resource "aws_iam_policy_attachment" "web" {
  name       = "${var.name}"
  roles      = ["${aws_iam_role.web.name}"]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_instance" "web" {
  ami                         = "${var.instance_ami_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${var.public_subnet_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.web.id}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags { Name = "${var.name}" }
}

resource "aws_cloudwatch_metric_alarm" "web" {
  alarm_name          = "CPU_Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = ["${var.sns_topic_arn}"]
}

output "public_ip" { value = "${aws_instance.web.public_ip}" }
