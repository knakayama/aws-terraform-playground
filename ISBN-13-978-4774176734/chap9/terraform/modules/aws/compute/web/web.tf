variable "name"              { default = "web" }
variable "vpc_id"            { }
variable "key_name"          { }
variable "public_subnet_ids" { }
variable "instance_type"     { }
variable "instance_ami_id"   { }
variable "desired_capacity"  { }
variable "max_size"          { }
variable "min_size"          { }

resource "aws_iam_server_certificate" "elb" {
  name             = "${var.name}-elb"
  certificate_body = "${file(concat(path.module, "/", "certs/server.crt"))}"
  private_key      = "${file(concat(path.module, "/", "certs/server.key"))}"
}

resource "aws_security_group" "elb" {
  name        = "${var.name}-elb"
  vpc_id      = "${var.vpc_id}"
  description = "ELB SG"

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

  tags { Name = "${var.name}-elb" }
}

resource "aws_security_group" "web" {
  name        = "${var.name}-web"
  vpc_id      = "${var.vpc_id}"
  description = "Web SG"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags { Name = "${var.name}-web" }
}

resource "aws_s3_bucket" "elb" {
  bucket        = "${var.name}-elb-log"
  acl           = "public-read-write"
  force_destroy = true
}

resource "aws_elb" "elb" {
  name                        = "elb"
  subnets                     = ["${split(",", var.public_subnet_ids)}"]
  security_groups             = ["${aws_security_group.elb.id}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  idle_timeout                = 60

  access_logs {
    bucket   = "${aws_s3_bucket.elb.id}"
    interval = 60
  }

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = "${aws_iam_server_certificate.elb.arn}"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
  }
}

resource "aws_launch_configuration" "autoscaling" {
  name                        = "${var.name}-autoscaling"
  image_id                    = "${var.instance_ami_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.web.id}"]
  associate_public_ip_address = true
  enable_monitoring           = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  lifecycle {
    create_before_destory = true
  }

  user_data = <<EOT
#!/bin/bash

yum update -y
yum install httpd -y
service httpd start
uname -n > /var/www/html/index.html
EOT
}

resource "aws_sqs_queue" "sns" {
  name = "${var.name}"
}

resource "aws_sns_topic" "sns" {
  name = "${var.name}"
}

resource "aws_sns_topic_subscription" "sns" {
  topic_arn = "${aws_sns_topic.sns.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.sns.arn}"
}

resource "aws_autoscaling_group" "autoscaling" {
  name                      = "${var.name}"
  launch_configuration      = "${aws_launch_configuration.autoscaling.name}"
  vpc_zone_identifier       = ["${split(",", var.public_subnet_ids)}"]
  #desired_capacity          = "${var.desired_capacity}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  load_balancers            = ["${aws_elb.elb.id}"]

  lifecycle {
    create_before_destory = true
  }

  tag {
    key   = "Name"
    value = "${var.name}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "autoscaling_add" {
  name                   = "${var.name}-add"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.autoscaling.name}"
}

resource "aws_autoscaling_policy" "autoscaling_remove" {
  name                   = "${var.name}-remove"
  scaling_adjustment     = "-2"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.autoscaling.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale-out-alarm" {
  alarm_name          = "scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [
    "${aws_autoscaling_policy.autoscaling_add.arn}",
    "${aws_sns_topic_subscription.sns.arn}"
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.autoscaling.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "scale-in-alarm" {
  alarm_name          = "scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 30
  alarm_actions       = [
    "${aws_autoscaling_policy.autoscaling_remove.arn}",
    "${aws_sns_topic_subscription.sns.arn}"
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.autoscaling.name}"
  }
}

output "elb_dns_name" { value = "${aws_elb.elb.dns_name}" }
output "elb_zone_id"  { value = "${aws_elb.elb.zone_id}" }
