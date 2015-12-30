variable "name"              { default = "web" }
variable "vpc_id"            { }
variable "key_name"          { }
variable "public_subnet_ids" { }
variable "instance_type"     { }
variable "instance_ami_id"   { }
variable "desired_capacity"  { }
variable "max_size"          { }
variable "min_size"          { }

variable "rel_path" {
  default = "../../../modules/aws/compute/web/"
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

  tags { Name = "${var.name}-web" }
}

resource "aws_launch_configuration" "autoscaling" {
  name              = "${var.name}-autoscaling"
  image_id          = "${var.instance_ami_id}"
  instance_type     = "${var.instance_type}"
  key_name          = "${var.key_name}"
  security_groups   = ["${aws_security_group.web.id}"]
  enable_monitoring = true
  user_data         = "${file(concat(var.rel_path, "user_data.sh"))}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  lifecycle {
    create_before_destory = true
  }
}

resource "aws_autoscaling_group" "autoscaling" {
  name                      = "${var.name}"
  launch_configuration      = "${aws_launch_configuration.autoscaling.name}"
  vpc_zone_identifier       = ["${split(",", var.public_subnet_ids)}"]
  #desired_capacity          = "${var.desired_capacity}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  default_cooldown          = 300
  force_delete              = true

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
  scaling_adjustment     = "-1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.autoscaling.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "scale_out_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = ["${aws_autoscaling_policy.autoscaling_add.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.autoscaling.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "scale_in_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 20
  alarm_actions       = ["${aws_autoscaling_policy.autoscaling_remove.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.autoscaling.name}"
  }
}
