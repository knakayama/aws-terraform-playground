resource "aws_key_pair" "default" {
  key_name   = "default"
  public_key = "${file(var.public_key)}"
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
