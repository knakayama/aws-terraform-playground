variable "name"             { default = "web" }
variable "vpc_id"           { }
variable "key_name"         { }
variable "public_subnet_id" { }
variable "instance_type"    { }
variable "instance_ami_id"  { }

resource "aws_security_group" "web" {
  name        = "${var.name}-web"
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

  tags { Name = "${var.name}-web" }
}

resource "aws_iam_role" "web" {
  name = "${var.name}"
  assume_role_policy = "${file(concat(path.module, "/", "assume_role_policy.json"))}"
}

resource "aws_iam_role_policy" "web" {
  name   = "${var.name}"
  role   = "${aws_iam_role.web.id}"
  policy = "${file(concat(path.module, "/", "role_policy.json"))}"
}

resource "aws_iam_instance_profile" "web" {
  name  = "${var.name}"
  roles = ["${aws_iam_role.web.name}"]
}

resource "aws_instance" "web" {
  ami                    = "${var.instance_ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  subnet_id              = "${var.public_subnet_id}"
  iam_instance_profile   = "${aws_iam_instance_profile.web.id}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags { Name = "${var.name}" }
}

output "public_ip" { value = "${aws_instance.web.public_ip}" }
