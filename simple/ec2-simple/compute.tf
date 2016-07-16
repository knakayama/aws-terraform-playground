resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file("site_key.pub")}"
}

resource "aws_spot_instance_request" "web" {
  spot_price                  = "${var.spot_price}"
  spot_type                   = "${var.spot_type}"
  wait_for_fulfillment        = "${var.wait_for_fulfillment}"
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.web_instance_type}"
  key_name                    = "${aws_key_pair.site_key.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${aws_subnet.public.id}"
  user_data                   = "${file("cloud_config.yml")}"
  associate_public_ip_address = true

  #block_duration_minutes      = 60

  tags {
    Name = "${var.name}"
  }
}
