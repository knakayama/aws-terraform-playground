variable name              { default = "nat" }
variable vpc_id            { }
variable vpc_cidr          { }
variable region            { }
variable public_subnets    { }
variable public_subnet_ids { }
variable private_subnets   { }
variable key_name          { }
variable instance_type     { }
variable ami_id            { }

resource "aws_security_group" "nat" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "NAT security group"

  tags { Name = "${var.name}" }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnets}"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnets}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnets}"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat" {
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(split(",", var.public_subnet_ids), count.index)}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.nat.id}"]
  source_dest_check           = false
  associate_public_ip_address = true

  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }

  tags { role = "${var.name}.${count.index+1}" }
}

output "instance_ids" { value = "${join(",", aws_instance.nat.*.id)}" }
output "private_ips"  { value = "${join(",", aws_instance.nat.*.private_ip)}" }
output "public_ips"   { value = "${join(",", aws_instance.nat.*.public_ip)}" }
