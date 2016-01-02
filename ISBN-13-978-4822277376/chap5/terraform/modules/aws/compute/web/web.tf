variable "name"              { default = "web" }
variable "vpc_id"            { }
variable "azs"               { }
variable "key_name"          { }
variable "public_subnet_ids" { }
variable "instance_type"     { }
variable "instance_ami_id"   { }
variable "max_size"          { }
variable "min_size"          { }

resource "aws_security_group" "elb" {
  name        = "${var.name}-elb"
  vpc_id      = "${var.vpc_id}"
  description = "Web SG"

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
  name                        = "elb"
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
    timeout  = 5
    target   = "HTTP:80/index.html"
    interval = 30
    healthy_threshold   = 10
    unhealthy_threshold = 2
  }
}

resource "aws_launch_configuration" "web" {
  name              = "${var.name}-web"
  image_id          = "${var.instance_ami_id}"
  instance_type     = "${var.instance_type}"
  key_name          = "${var.key_name}"
  security_groups   = ["${aws_security_group.web.id}"]
  enable_monitoring = true
  associate_public_ip_address = true

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
yum install httpd mysql -y
service httpd start
uname -n > /var/www/html/index.html
EOT
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.name}"
  launch_configuration      = "${aws_launch_configuration.web.name}"
  vpc_zone_identifier       = ["${split(",", var.public_subnet_ids)}"]
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
  threshold           = 50
  alarm_actions       = ["${aws_autoscaling_policy.web_add.arn}"]

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
  threshold           = 10
  alarm_actions       = ["${aws_autoscaling_policy.web_remove.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }
}

output "web_sg_id"    { value = "${aws_security_group.web.id}" }
output "elb_dns_name" { value = "${aws_elb.elb.dns_name}" }
output "elb_zone_id"  { value = "${aws_elb.elb.zone_id}" }
