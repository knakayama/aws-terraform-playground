variable "name"              { default = "web" }
variable "region"            { }
variable "vpc_id"            { }
variable "azs"               { }
variable "key_name"          { }
variable "public_subnet_ids" { }
variable "instance_type"     { }
variable "instance_ami_id"   { }
variable "max_size"          { }
variable "min_size"          { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name}-lambda"
  assume_role_policy = "${file(concat(path.module, "/assume_role_policy_lambda.json"))}"
}

resource "aws_iam_role" "autoscaling" {
  name               = "${var.name}-autoscaling"
  assume_role_policy = "${file(concat(path.module, "/assume_role_policy_autoscaling.json"))}"
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "${var.name}-lambda"
  roles      = ["${aws_iam_role.lambda.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "autoscaling" {
  name       = "${var.name}-autoscaling"
  roles      = ["${aws_iam_role.autoscaling.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_lambda_function" "lambda" {
  filename      = "${concat(path.module, "/notify_to_slack.zip")}"
  function_name = "notify-to-slack"
  description   = "Notify to slack"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "index.handler"
  runtime       = "python2.7"
}

resource "aws_sns_topic" "lambda" {
  name         = "${var.name}-from-lambda"
  display_name = "${var.name}-from-lambda"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = "${aws_sns_topic.lambda.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda.arn}"
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

  tags { Name = "${var.name}" }
}

resource "aws_security_group" "web" {
  name        = "${var.name}-web"
  vpc_id      = "${var.vpc_id}"
  description = "Web SG"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags { Name = "${var.name}" }
}

resource "aws_elb" "elb" {
  name                        = "${var.name}-elb"
  subnets                     = ["${split(",", var.public_subnet_ids)}"]
  idle_timeout                = 60
  security_groups             = ["${aws_security_group.elb.id}"]
  connection_draining         = true
  connection_draining_timeout = 300
  cross_zone_load_balancing   = true

  listener {
    lb_port            = 80
    lb_protocol        = "http"
    instance_port      = 80
    instance_protocol  = "http"
  }

  health_check {
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
    healthy_threshold   = 10
    unhealthy_threshold = 2
  }
}

resource "aws_launch_configuration" "web" {
  name                        = "${var.name}-web"
  image_id                    = "${var.instance_ami_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  user_data                   = "${file(concat(path.module, "/cloud-init.yml"))}"
  security_groups             = ["${aws_security_group.web.id}"]
  enable_monitoring           = true
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.name}-web"
  launch_configuration      = "${aws_launch_configuration.web.name}"
  vpc_zone_identifier       = ["${split(",", var.public_subnet_ids)}"]
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  load_balancers            = ["${aws_elb.elb.id}"]

  tag {
    key   = "Name"
    value = "${var.name}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "web_add" {
  name                   = "web_add"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_autoscaling_policy" "web_remove" {
  name                   = "web_remove"
  scaling_adjustment     = "-1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web_scale_out" {
  alarm_name          = "web_scale_out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 10
  alarm_actions       = [
    "${aws_autoscaling_policy.web_add.arn}",
    "${aws_sns_topic.lambda.arn}"
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "web_scale_in" {
  alarm_name          = "web_scale_in"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 5
  alarm_actions       = [
    "${aws_autoscaling_policy.web_remove.arn}",
    "${aws_sns_topic.lambda.arn}"
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }
}

resource "aws_autoscaling_lifecycle_hook" "web" {
    name                    = "web"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 2000
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
    autoscaling_group_name  = "${aws_autoscaling_group.web.name}"
    notification_target_arn = "${aws_sns_topic.lambda.arn}"
    role_arn                = "${aws_iam_role.autoscaling.arn}"
}

output "web_sg_id"    { value = "${aws_security_group.web.id}" }
output "elb_dns_name" { value = "${aws_elb.elb.dns_name}" }
output "elb_zone_id"  { value = "${aws_elb.elb.zone_id}" }
