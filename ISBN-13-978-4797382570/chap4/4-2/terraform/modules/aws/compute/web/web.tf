variable "name"               { default = "web" }
variable "region"             { }
variable "vpc_id"             { }
variable "key_name"           { }
variable "private_key"        { }
variable "public_subnet_id"   { }
variable "instance_type"      { }
variable "instance_ami_id"    { }
variable "role_policy"        { }
variable "assume_role_policy" { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "web" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Web SG"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags { Name = "${var.name}" }
}

resource "aws_iam_role" "web" {
  name               = "${var.name}"
  assume_role_policy = "${var.assume_role_policy}"
}

resource "aws_iam_policy_attachment" "web" {
  name       = "${var.name}"
  roles      = ["${aws_iam_role.web.name}"]
  policy_arn = "${var.role_policy}"
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.name}"
  roles = ["${aws_iam_role.web.name}"]
}

resource "aws_instance" "web" {
  ami                         = "${var.instance_ami_id}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${var.public_subnet_id}"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.web.id}"
  associate_public_ip_address = true
  user_data                   = "${file(concat(path.module, "/cloud-init.yml"))}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }

  provisioner "file" {
    source      = "${concat(path.module, "/ses.rb")}"
    destination = "/home/ec2-user/ses.rb"

    connection {
      user        = "ec2-user"
      private_key = "${file(var.private_key)}"
    }
  }

  tags { Name = "${var.name}" }
}

output "public_ip" { value = "${aws_instance.web.public_ip}" }
