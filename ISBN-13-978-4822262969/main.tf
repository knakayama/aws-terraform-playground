provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

# VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "my-vpc"
  }
}

# Subnet
## public
resource "aws_subnet" "public-a" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags {
    Name = "my-subnet-public-a"
  }
}
## private
resource "aws_subnet" "private-c" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "my-subnet-private-c"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  tags {
    Name = "my-igw"
  }
}

# Route Table
resource "aws_route_table" "my-route-public" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my-igw.id}"
  }
  tags {
    Name = "my-route-table-public"
  }
}
resource "aws_route_table" "my-route-private" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.my-nat.id}"
  }
  tags {
    Name = "my-route-table-private"
  }
}
resource "aws_route_table_association" "my-assoc-public" {
  subnet_id = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.my-route-public.id}"
}
resource "aws_route_table_association" "my-route-private" {
  subnet_id = "${aws_subnet.private-c.id}"
  route_table_id = "${aws_route_table.my-route-private.id}"
}

# Security Group
## Web
resource "aws_security_group" "my-web-sg" {
  name = "my-web-sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id = "${aws_vpc.my-vpc.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "my-web-sg"
  }
}
## DB
resource "aws_security_group" "my-db-sg" {
  name = "my-db-sg"
  description = "Allow SSH and 3306 inbound traffic"
  vpc_id = "${aws_vpc.my-vpc.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "my-db-sg"
  }
}
## NAT
resource "aws_security_group" "my-nat-sg" {
  name = "my-nat-sg"
  description = "Allow ssh/http/https inbound traffic"
  vpc_id = "${aws_vpc.my-vpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "my-nat-sg"
  }
}

# Key Pair
resource "aws_key_pair" "my-key" {
  key_name = "my-key"
  public_key = "${var.aws_public_key}"
}

# EC2 Instance
## web
resource "aws_instance" "my-web" {
  ami = "ami-383c1956"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.my-web-sg.id}"
  ]
  subnet_id = "${aws_subnet.public-a.id}"
  associate_public_ip_address = false
  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }
  tags {
    role = "web"
  }
  key_name = "${aws_key_pair.my-key.key_name}"
  user_data = "${file("bin/bootstrap.sh")}"
  # FIXME: not work...
  #provisioner "local-exec" {
  #  command = "./bin/run.sh"
  #}
}
## nat
resource "aws_instance" "my-nat" {
  ami = "ami-03cf3903"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.my-nat-sg.id}"
  ]
  subnet_id = "${aws_subnet.public-a.id}"
  associate_public_ip_address = true
  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }
  tags {
    role = "nat"
  }
  key_name = "${aws_key_pair.my-key.key_name}"
  source_dest_check = false
}
## db
resource "aws_instance" "my-db" {
  ami = "ami-383c1956"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.my-db-sg.id}"
  ]
  subnet_id = "${aws_subnet.private-c.id}"
  associate_public_ip_address = false
  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }
  tags {
    role = "db"
  }
  key_name = "${aws_key_pair.my-key.key_name}"
  user_data = "${file("bin/bootstrap.sh")}"
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${var.aws_private_key}"
      bastion_host = "${aws_instance.my-web.public_ip}"
      bastion_user = "ec2-user"
      bastion_private_key = "${var.aws_private_key}"
    }
    script = "bin/db.sh"
  }
}

# EIP
resource "aws_eip" "my-eip" {
  instance = "${aws_instance.my-web.id}"
  vpc = true
}

# Output
output "my-web public ip" {
  value = "${aws_instance.my-web.public_ip}"
}
output "my-db private ip" {
  value = "${aws_instance.my-web.private_ip}"
}
output "my-nat private ip" {
  value = "${aws_instance.my-nat.private_ip}"
}
