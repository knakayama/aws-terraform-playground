variable "name"                      { default = "db" }
variable "vpc_id"                    { }
variable "key_name"                  { }
variable "private_subnet_id"         { }
variable "instance_type"             { }
variable "instance_ami_id"           { }
variable "bastion_security_group_id" { }

resource "aws_security_group" "db" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "DB SG"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${var.bastion_security_group_id}"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${var.bastion_security_group_id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags { Name = "${var.name}" }
}

resource "aws_instance" "db" {
  ami                    = "${var.instance_ami_id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  subnet_id              = "${var.private_subnet_id}"
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

output "private_ip" { value = "${aws_instance.db.private_ip}" }
