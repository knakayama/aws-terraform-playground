resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file("keys/site_key.pub")}"
}

resource "aws_spot_instance_request" "ec2" {
  spot_price                  = "${var.spot_price}"
  spot_type                   = "${var.spot_type}"
  wait_for_fulfillment        = true
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.site_key.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.ec2.id}"]
  subnet_id                   = "${aws_subnet.public.id}"
  user_data                   = "${file("user_data/cloud_config.yml")}"
  associate_public_ip_address = true

  tags {
    Name = "${var.name}"
  }
}
