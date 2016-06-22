resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file("site_key.pub")}"
}

resource "aws_instance" "web" {
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "${var.web_instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${element(aws_subnet.public.*.id, 1)}"
  key_name                    = "${aws_key_pair.site_key.key_name}"
  user_data                   = "${file("cloud_config.yml")}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}-web"
  }
}
