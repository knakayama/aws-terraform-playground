resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file("site_key.pub")}"
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name}-role"
  assume_role_policy = "${file("assume_role_policy.json")}"
}

resource "aws_iam_instance_profile" "ec2" {
  name  = "${var.name}-role"
  roles = ["${aws_iam_role.ec2.name}"]
}

resource "aws_iam_policy_attachment" "ec2" {
  name       = "S3FullAccess"
  roles      = ["${aws_iam_role.ec2.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_instance" "public" {
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.nano"
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  subnet_id              = "${aws_subnet.public.id}"
  iam_instance_profile   = "${aws_iam_instance_profile.ec2.id}"
  key_name               = "${aws_key_pair.site_key.key_name}"
  user_data              = "${file("cloud_config.yml")}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_instance" "private" {
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.nano"
  vpc_security_group_ids = ["${aws_security_group.private.id}"]
  subnet_id              = "${aws_subnet.private.id}"
  iam_instance_profile   = "${aws_iam_instance_profile.ec2.id}"
  key_name               = "${aws_key_pair.site_key.key_name}"
  user_data              = "${file("cloud_config.yml")}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags {
    Name = "${var.name}"
  }
}
