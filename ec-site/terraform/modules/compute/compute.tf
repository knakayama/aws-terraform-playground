variable "name" {}

variable "key_name" {}

variable "vpc_id" {}

variable "azs" {}

variable "public_subnet_ids" {}

variable "private_subnet_ids_web" {}

variable "web_ap_admin_type" {}

variable "web_ap_admin_ami_id" {}

variable "web_ap_public_type" {}

variable "web_ap_public_ami_id" {}

variable "web_ap_public_max_size" {}

variable "web_ap_public_min_size" {}

resource "aws_security_group" "elb_admin" {
  name        = "${var.name}-elb-admin"
  vpc_id      = "${var.vpc_id}"
  description = "${var.name}-elb-admin"

  ingress {
    from_port   = 1022
    to_port     = 1022
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

  tags {
    Name = "${var.name}-elb-ap-admin"
  }
}

resource "aws_security_group" "elb_public" {
  name        = "${var.name}-elb-public"
  vpc_id      = "${var.vpc_id}"
  description = "${var.name}-elb-public"

  ingress {
    from_port   = 1022
    to_port     = 1022
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

  tags {
    Name = "${var.name}-elb-ap-public"
  }
}

resource "aws_security_group" "web_ap_admin" {
  name        = "${var.name}-web-ap-admin"
  vpc_id      = "${var.vpc_id}"
  description = "${var.name}-web-ap-admin"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_admin.id}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_admin.id}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_admin.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-web-ap-admin"
  }
}

resource "aws_security_group" "web_ap_public" {
  name        = "${var.name}-web-ap-public"
  vpc_id      = "${var.vpc_id}"
  description = "${var.name}-web-ap-public"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_public.id}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_public.id}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_public.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-web-ap-public"
  }
}

resource "aws_iam_server_certificate" "elb" {
  name             = "${var.name}"
  private_key      = "${file(concat(path.module, "/certs/server.key"))}"
  certificate_body = "${file(concat(path.module, "/certs/server.crt"))}"
}

resource "aws_elb" "elb_admin" {
  count                       = "${length(split(",", var.azs))}"
  name                        = "${var.name}-elb-admin${count.index+1}"
  subnets                     = ["${split(",", var.public_subnet_ids)}"]
  security_groups             = ["${aws_security_group.elb_admin.id}"]
  instances                   = ["${aws_instance.web_ap_admin.*.id}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  idle_timeout                = 60

  listener {
    lb_port           = 1022
    lb_protocol       = "tcp"
    instance_port     = 22
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 443
    instance_protocol  = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.elb.arn}"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  tags {
    Name = "${var.name}-elb-admin${count.index+1}"
  }
}

resource "aws_elb" "elb_public" {
  count                       = "${length(split(",", var.azs))}"
  name                        = "${var.name}-elb-public${count.index+1}"
  subnets                     = ["${split(",", var.public_subnet_ids)}"]
  security_groups             = ["${aws_security_group.elb_public.id}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  idle_timeout                = 60

  listener {
    lb_port           = 1022
    lb_protocol       = "tcp"
    instance_port     = 22
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
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

  tags {
    Name = "${var.name}-elb-public${count.index+1}"
  }
}

resource "aws_instance" "web_ap_admin" {
  count                       = "${length(split(",", var.azs))}"
  ami                         = "${var.web_ap_admin_ami_id}"
  instance_type               = "${var.web_ap_admin_type}"
  subnet_id                   = "${element(split(",", var.private_subnet_ids_web), count.index)}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.web_ap_admin.id}"]
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = "${file(concat(path.module, "/cloud-init.yml"))}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}-web-ap-admin${count.index+1}"
  }
}

resource "aws_launch_configuration" "web_ap_public" {
  name_prefix                 = "${var.name}-web-ap-public"
  image_id                    = "${var.web_ap_public_ami_id}"
  instance_type               = "${var.web_ap_public_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.web_ap_public.id}"]
  user_data                   = "${file(concat(path.module, "/cloud-init.yml"))}"
  associate_public_ip_address = false
  enable_monitoring           = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_ap_public" {
  count                     = "${length(split(",", var.azs))}"
  name                      = "${var.name}-web-ap-public${count.index+1}"
  launch_configuration      = "${aws_launch_configuration.web_ap_public.name}"
  vpc_zone_identifier       = ["${element(split(",", var.private_subnet_ids_web), count.index)}"]
  max_size                  = "${var.web_ap_public_max_size}"
  min_size                  = "${var.web_ap_public_min_size}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  load_balancers            = ["${aws_elb.elb_public.*.id}"]

  tag {
    key                 = "Name"
    value               = "${var.name}-web-ap-public${count.index+1}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "web_ap_public_scale_out" {
  count                  = "${length(split(",", var.azs))}"
  name                   = "${var.name}-web-ap-public-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${element(aws_autoscaling_group.web_ap_public.*.name, count.index)}"
}

resource "aws_autoscaling_policy" "web_ap_public_scale_in" {
  count                  = "${length(split(",", var.azs))}"
  name                   = "${var.name}-web-ap-public-scale-in"
  scaling_adjustment     = "-1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${element(aws_autoscaling_group.web_ap_public.*.name, count.index)}"
}

resource "aws_cloudwatch_metric_alarm" "web_ap_public_scale_out" {
  count               = "${length(split(",", var.azs))}"
  alarm_name          = "${var.name}-web-ap-public-scale-out"
  alarm_actions       = ["${element(aws_autoscaling_policy.web_ap_public_scale_out.*.arn, count.index)}"]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 20

  dimensions {
    AutoScalingGroupName = "${element(aws_autoscaling_group.web_ap_public.*.name, count.index)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "web_ap_public_scale_in" {
  count               = "${length(split(",", var.azs))}"
  alarm_name          = "${var.name}-web-ap-public-scale-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  alarm_actions       = ["${element(aws_autoscaling_policy.web_ap_public_scale_in.*.arn, count.index)}"]
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  period              = 300
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 5

  dimensions {
    AutoScalingGroupName = "${element(aws_autoscaling_group.web_ap_public.*.name, count.index)}"
  }
}

output "web_ap_admin_sg_id" {
  value = "${aws_security_group.web_ap_admin.id}"
}

output "web_ap_public_sg_id" {
  value = "${aws_security_group.web_ap_public.id}"
}

output "elb_admin_zone_ids" {
  value = "${join(",", aws_elb.elb_admin.*.zone_id)}"
}

output "elb_admin_dns_names" {
  value = "${join(",", aws_elb.elb_admin.*.dns_name)}"
}

output "elb_public_zone_ids" {
  value = "${join(",", aws_elb.elb_public.*.zone_id)}"
}

output "elb_public_dns_names" {
  value = "${join(",", aws_elb.elb_public.*.dns_name)}"
}

output "web_ap_admin_private_ips" {
  value = "${join(",", aws_instance.web_ap_admin.*.private_ip)}"
}
