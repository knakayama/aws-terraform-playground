resource "aws_key_pair" "keypair" {
  key_name   = "${var.name}"
  public_key = "${file("site_key.pub")}"
}

resource "aws_launch_configuration" "lc" {
  name_prefix                 = "${var.name}-"
  image_id                    = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.instance_types["compute"]}"
  key_name                    = "${aws_key_pair.keypair.key_name}"
  security_groups             = ["${aws_security_group.compute.id}"]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  lifecycle {
    create_before_destroy = true
  }
}
