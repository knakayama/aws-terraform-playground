variable "name"              { default = "bastion" }
variable "vpc_id"            { }
variable "vpc_cidr"          { }
variable "region"            { }
variable "public_subnet_ids" { }
variable "key_name"          { }
variable "instance_type"     { }
variable "ami_id"            { }

resource "aws_security_group" "bastion" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion security group"

  tags { Name = "${var.name}" }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(split(",", var.public_subnet_ids), count.index)}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = false
  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }

  tags { role = "${var.name}" }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}

output "user"       { value = "ec2-user" }
output "private_ip" { value = "${aws_instance.bastion.private_ip}" }
output "public_ip"  { value = "${aws_eip.bastion.public_ip}" }
