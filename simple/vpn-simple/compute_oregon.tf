resource "aws_key_pair" "site_key_oregon" {
  provider   = "aws.oregon"
  key_name   = "${var.name}"
  public_key = "${file("${path.module}/keys/site_key.pub")}"
}

resource "aws_instance" "ec2_oregon" {
  count                       = 2
  provider                    = "aws.oregon"
  ami                         = "${data.aws_ami.amazon_linux_oregon.id}"
  instance_type               = "${var.ec2_instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.ec2_oregon.id}"]
  subnet_id                   = "${element(aws_subnet.public_oregon.*.id, count.index)}"
  key_name                    = "${aws_key_pair.site_key_oregon.key_name}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}-ec2-oregon-${count.index + 1}"
  }
}
