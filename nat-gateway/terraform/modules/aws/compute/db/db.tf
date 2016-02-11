variable "name"                  { default = "web" }
variable "vpc_id"                { }
variable "public_subnet_id"      { }
variable "private_subnet_id"     { }
variable "web_security_group_id" { }
variable "key_name"              { }
variable "instance_type"         { }
variable "ami_id"                { }

resource "aws_security_group" "db" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "DB SG"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${var.web_security_group_id}"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${var.web_security_group_id}"]
  }

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = ["${var.web_security_group_id}"]
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
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.private_subnet_id}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.db.id}"]
  associate_public_ip_address = false
  user_data                   = "${file(concat(path.module, "/cloud-init.yml"))}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }

  tags { Name = "${var.name}" }
}

output "private_ip" { value = "${aws_instance.db.private_ip}" }
