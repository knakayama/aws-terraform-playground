resource "aws_key_pair" "site_key_tokyo" {
  key_name   = "${var.name}"
  public_key = "${file("site_key.pub")}"
}

resource "aws_instance" "vyos_tokyo" {
  ami                         = "${data.aws_ami.vyos_ami.id}"
  instance_type               = "${var.vyos_instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.vyos_tokyo.id}"]
  subnet_id                   = "${aws_subnet.public_tokyo.id}"
  key_name                    = "${aws_key_pair.site_key_tokyo.key_name}"
  source_dest_check           = false
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 4
  }

  tags {
    Name = "${var.name}-vyos-tokyo"
  }
}

resource "aws_instance" "web_tokyo" {
  ami                         = "${data.aws_ami.amazon_linux_tokyo.id}"
  instance_type               = "${var.vyos_instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.web_tokyo.id}"]
  subnet_id                   = "${aws_subnet.public_tokyo.id}"
  key_name                    = "${aws_key_pair.site_key_tokyo.key_name}"
  user_data                   = "${file("cloud_config.yml")}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}-web-tokyo"
  }
}
