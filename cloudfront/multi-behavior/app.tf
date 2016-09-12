#data "template_file" "user_data" {

#  template = "${path.module}/user_data/app_cloud_config.yml.tpl"

#

#  vars {

#    s3_domain

#  }

#}

resource "aws_launch_configuration" "app" {
  name_prefix                 = "${var.name}-app-"
  image_id                    = "${var.amazon_linux_id}"
  instance_type               = "${var.instance_types["app"]}"
  key_name                    = "${aws_key_pair.key_pair.key_name}"
  security_groups             = ["${aws_security_group.app.id}"]
  iam_instance_profile        = "${var.instance_profile_id}"
  user_data                   = "${file("${path.module}/user_data/app_cloud_config.yml")}"
  associate_public_ip_address = false

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "${var.name}-asg"
  launch_configuration      = "${aws_launch_configuration.app.name}"
  vpc_zone_identifier       = ["${aws_subnet.application_subnet.*.id}"]
  min_size                  = "${var.asg_config["min"]}"
  max_size                  = "${var.asg_config["max"]}"
  desired_capacity          = "${var.asg_config["desired"]}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  load_balancers            = ["${aws_elb.elb.id}"]

  tag {
    key                 = "Name"
    value               = "${var.name}-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.name}-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.name}-scale-in"
  scaling_adjustment     = "-1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_out" {
  alarm_name          = "${var.name}-scale-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 30

  alarm_actions = [
    "${aws_autoscaling_policy.scale_out.arn}",
    "${module.tf_sns_email.arn}",
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.app.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_in" {
  alarm_name          = "${var.name}-scale-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 10

  alarm_actions = [
    "${aws_autoscaling_policy.scale_in.arn}",
    "${module.tf_sns_email.arn}",
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.app.name}"
  }
}
