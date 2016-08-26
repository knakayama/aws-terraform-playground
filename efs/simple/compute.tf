resource "aws_key_pair" "key_pair" {
  key_name   = "${var.name}"
  public_key = "${file("${path.module}/keys/key_pair.pub")}"
}

resource "aws_spot_instance_request" "web" {
  count                       = 2
  spot_price                  = "${var.spot_config["price"]}"
  spot_type                   = "${var.spot_config["type"]}"
  wait_for_fulfillment        = "${var.spot_config["wait_for_fulfillment"]}"
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.spot_config["instance_type"]}"
  key_name                    = "${aws_key_pair.key_pair.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${aws_subnet.public.id}"
  user_data                   = "${file("${path.module}/user_data/cloud_config.yml")}"
  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.id}"
  associate_public_ip_address = true

  tags {
    Name = "${var.name}-${count.index}"
  }
}
