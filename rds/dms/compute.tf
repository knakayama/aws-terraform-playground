resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file("${path.module}/keys/key_pair.pub")}"
}

resource "aws_instance" "ec2_1" {
  ami                         = "${var.amazon_linux_id}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.ec2.0.id}"]
  subnet_id                   = "${aws_subnet.public1.0.id}"
  key_name                    = "${aws_key_pair.site_key.key_name}"
  user_data                   = "${file("${path.module}/user_data/ec2_cloud_config.yml")}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}-ec2"
  }
}

resource "aws_instance" "ec2_2" {
  ami                         = "${var.amazon_linux_id}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.ec2.1.id}"]
  subnet_id                   = "${aws_subnet.public2.0.id}"
  key_name                    = "${aws_key_pair.site_key.key_name}"
  user_data                   = "${file("${path.module}/user_data/ec2_cloud_config.yml")}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}-ec2"
  }
}
