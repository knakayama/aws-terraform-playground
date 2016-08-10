resource "aws_key_pair" "key_pair" {
  key_name   = "${var.name}"
  public_key = "${file("${path.module}/keys/key_pair.pub")}"
}

resource "aws_launch_configuration" "asg" {
  name_prefix                 = "${var.name}-asg-"
  image_id                    = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.asg_config["instance_type"]}"
  key_name                    = "${aws_key_pair.key_pair.key_name}"
  security_groups             = ["${aws_security_group.asg.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.asg.id}"
  user_data                   = "${file("${path.module}/user_data/asg_cloud_config.yml")}"
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
  launch_configuration      = "${aws_launch_configuration.asg.name}"
  vpc_zone_identifier       = ["${aws_subnet.public.id}"]
  desired_capacity          = "${var.asg_config["desired"]}"
  max_size                  = "${var.asg_config["max"]}"
  min_size                  = "${var.asg_config["min"]}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  load_balancers            = ["${aws_elb.elb.id}"]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
