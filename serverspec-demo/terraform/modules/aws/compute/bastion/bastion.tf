variable "name"              { default = "bastion" }
variable "vpc_id"            { }
variable "key_name"          { }
variable "public_subnet_id"  { }
variable "instance_type"     { }
variable "instance_ami_id"   { }

resource "aws_security_group" "bastion" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion SG"

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

resource "aws_instance" "bastion" {
  ami                    = "${var.instance_ami_id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  subnet_id              = "${var.public_subnet_id}"
  key_name               = "${var.key_name}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  user_data = <<EOT
#cloud-config
repo_update: true
repo_upgrade: all
timezone: "Asia/Tokyo"
EOT

  tags { Name = "${var.name}" }
}

output "public_ip"         { value = "${aws_instance.bastion.public_ip}" }
output "security_group_id" { value = "${aws_security_group.bastion.id}" }
