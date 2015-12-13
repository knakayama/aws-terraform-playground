provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_iam_group" "chap2-iam-group" {
  name = "chap2-iam-group"
  path = "/"
}

resource "aws_iam_group_policy" "chap2-iam-group-policy" {
  name = "${aws_iam_group.chap2-iam-group.name}"
  group = "${aws_iam_group.chap2-iam-group.id}"
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOT
}

resource "aws_iam_user" "chap2-iam-user" {
  name = "chap2-iam-user"
}

resource "aws_iam_group_membership" "chap2-iam-membership" {
  name = "chap2-iam-membership"
  users = [
    "${aws_iam_user.chap2-iam-user.name}"
  ]
  group = "${aws_iam_group.chap2-iam-group.name}"
}

resource "aws_vpc" "chap2-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "AWS_Book"
  }
}

resource "aws_subnet" "chap2-subnet-a" {
  vpc_id = "${aws_vpc.chap2-vpc.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"
  tags {
    Name = "AWS_Book_Subnet-a"
  }
}
resource "aws_subnet" "chap2-subnet-c" {
  vpc_id = "${aws_vpc.chap2-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "AWS_Book_Subnet-c"
  }
}

resource "aws_internet_gateway" "chap2-igw" {
  vpc_id = "${aws_vpc.chap2-vpc.id}"
  tags {
    Name = "AWS_Book_Gateway"
  }
}

resource "aws_route_table" "chap2-rt" {
  vpc_id = "${aws_vpc.chap2-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.chap2-igw.id}"
  }
  tags {
    Name = "AWS_Book_RouteTable"
  }
}

resource "aws_route_table_association" "chap2-assoc-a" {
  subnet_id = "${aws_subnet.chap2-subnet-a.id}"
  route_table_id = "${aws_route_table.chap2-rt.id}"
}
resource "aws_route_table_association" "chap2-assoc-c" {
  subnet_id = "${aws_subnet.chap2-subnet-c.id}"
  route_table_id = "${aws_route_table.chap2-rt.id}"
}

resource "aws_security_group" "chap2-instance-sg" {
  name = "AWS_Book_SecurityGroup_Instance"
  description = "AWS_Book_SecurityGroup_Instance"
  vpc_id = "${aws_vpc.chap2-vpc.id}"
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
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "chap2-elb-sg" {
  name = "AWS_Book_SecurityGroup_ELB"
  description = "AWS_Book_SecurityGroup_ELB"
  vpc_id = "${aws_vpc.chap2-vpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "chap2-key" {
  key_name = "chap2-key"
  public_key = "${var.aws_public_key}"
}

resource "aws_instance" "chap2-instance-a" {
  ami = "${var.aws_ami}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.chap2-instance-sg.id}"
  ]
  subnet_id = "${aws_subnet.chap2-subnet-a.id}"
  associate_public_ip_address = false
  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }
  tags {
    Name = "AWS_Book_Instance-a"
  }
  key_name = "${aws_key_pair.chap2-key.key_name}"
  user_data = "${file("bin/bootstrap.sh")}"
}
resource "aws_instance" "chap2-instance-c" {
  ami = "${var.aws_ami}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.chap2-instance-sg.id}"
  ]
  subnet_id = "${aws_subnet.chap2-subnet-c.id}"
  associate_public_ip_address = false
  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }
  tags {
    Name = "AWS_Book_Instance-c"
  }
  key_name = "${aws_key_pair.chap2-key.key_name}"
  user_data = "${file("bin/bootstrap.sh")}"
}

resource "aws_eip" "chap2-eip-a" {
  instance = "${aws_instance.chap2-instance-a.id}"
  vpc = true
}
resource "aws_eip" "chap2-eip-c" {
  instance = "${aws_instance.chap2-instance-c.id}"
  vpc = true
}

resource "aws_elb" "chap2-elb" {
  name = "AWS-Book-ELB"
  # * aws_elb.chap2-elb: ValidationError: Only one of SubnetIds or AvailabilityZones may be specified
  #availability_zones = [
  #  "${aws_instance.chap2-instance-a.availability_zone}",
  #  "${aws_instance.chap2-instance-c.availability_zone}"
  #]
  subnets = [
    "${aws_subnet.chap2-subnet-a.id}",
    "${aws_subnet.chap2-subnet-c.id}"
  ]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:80/index.html"
    interval = 30
  }
  instances = [
    "${aws_instance.chap2-instance-a.id}",
    "${aws_instance.chap2-instance-c.id}"
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 300
  security_groups = [
    "${aws_security_group.chap2-elb-sg.id}"
  ]
  tags {
    Name = "AWS_Book_ELB"
  }
}

output "chap2-instance-a public ip" {
  value = "${aws_instance.chap2-instance-a.public_ip}"
}
output "chap2-instance-c public ip" {
  value = "${aws_instance.chap2-instance-c.public_ip}"
}
output "chap2-elb dns name" {
  value = "${aws_elb.chap2-elb.dns_name}"
}
