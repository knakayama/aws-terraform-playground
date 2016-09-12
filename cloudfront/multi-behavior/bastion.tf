resource "aws_instance" "bastion" {
  ami                         = "${var.amazon_linux_id}"
  instance_type               = "${var.instance_types["bastion"]}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  subnet_id                   = "${element(aws_subnet.frontend_subnet.*.id, 1)}"
  key_name                    = "${aws_key_pair.key_pair.key_name}"
  user_data                   = "${file("${path.module}/user_data/bastion_cloud_config.yml")}"
  associate_public_ip_address = false

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}-bastion"
  }
}

resource "aws_eip" "eip" {
  vpc      = true
  instance = "${aws_instance.bastion.id}"
}
