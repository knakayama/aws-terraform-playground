resource "aws_key_pair" "site_key_oregon" {
  provider   = "aws.oregon"
  key_name   = "${var.name}"
  public_key = "${file("site_key.pub")}"
}

resource "aws_instance" "web_oregon" {
  provider                    = "aws.oregon"
  ami                         = "${data.aws_ami.amazon_linux_oregon.id}"
  instance_type               = "${var.web_instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.web_oregon.id}"]
  subnet_id                   = "${aws_subnet.public_oregon.id}"
  key_name                    = "${aws_key_pair.site_key_oregon.key_name}"
  user_data                   = "${file("cloud_config.yml")}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}-web-oregon"
  }
}
