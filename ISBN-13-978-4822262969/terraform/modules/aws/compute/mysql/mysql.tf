variable "name"               { default = "mysql" }
variable "vpc_id"             { }
variable "vpc_cidr"           { }
variable "public_subnets"     { }
variable "private_subnet_ids" { }
variable "key_name"           { }
variable "instance_type"      { }
variable "ami_id"             { }
variable "bastion_public_ip"  { }
variable "bastion_user"       { }

resource "aws_security_group" "mysql" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "MySQL security group"

  tags { Name = "${var.name}" }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnets}"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnets}"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.public_subnets}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mysql" {
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(split(",", var.private_subnet_ids), count.index)}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.mysql.id}"]
  associate_public_ip_address = false

  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }

  tags { Name = "${var.name}" }
}

output "private_ips" { value = "${join(",", aws_instance.mysql.*.private_ip)}" }
