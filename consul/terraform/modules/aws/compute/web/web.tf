variable "name"              { default = "web" }
variable "region"            { }
variable "key_name"          { }
variable "key_file"          { }
variable "vpc_ids"           { }
variable "azs"               { }
variable "public_subnet_ids" { }
variable "instance_type"     { }
variable "instance_ami_id"   { }
variable "platform"          { }

variable "public_subnets_table" {
  default = {
    "0" = "172.17.0.0/24"
    "1" = "172.16.0.0/24"
  }
}

# ref: https://github.com/hashicorp/consul/blob/master/terraform/aws/consul.tf

provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "web" {
  count       = "${length(split(",", var.azs))}"
  name        = "${var.name}"
  vpc_id      = "${element(split(",", var.vpc_ids), count.index)}"
  description = "Web SG ${element(split(",", var.vpc_ids), count.index)}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${lookup(var.public_subnets_table, count.index)}"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["${lookup(var.public_subnets_table, count.index)}"]
  }

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

  tags { Name = "${var.name}.${element(split(",", var.vpc_ids), count.index)}" }
}

resource "aws_instance" "web" {
  count                  = "${length(split(",", var.azs))}"
  ami                    = "${var.instance_ami_id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(split(",", var.public_subnet_ids), count.index)}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${element(aws_security_group.web.*.id, count.index)}"]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  connection {
    user        = "ec2-user"
    private_key = "${var.key_file}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/${var.platform}/upstart.conf"
    destination = "/tmp/upstart.conf"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/${var.platform}/upstart-join.conf"
    destination = "/tmp/upstart-join.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${length(split(",", var.vpc_ids))} > /tmp/consul-server-count",
      "echo ${aws_instance.web.0.private_ip} > /tmp/consul-server-addr"
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/${var.platform}/setup.sh",
      "${path.module}/scripts/${var.platform}/server.sh",
      "${path.module}/scripts/${var.platform}/service.sh",
    ]
  }

  tags { Name = "${var.name}.${element(split(",", var.vpc_ids), count.index)}" }
}

output "public_ips"  { value = "${join(",", aws_instance.web.*.public_ip)}" }
output "private_ips" { value = "${join(",", aws_instance.web.*.private_ip)}" }
