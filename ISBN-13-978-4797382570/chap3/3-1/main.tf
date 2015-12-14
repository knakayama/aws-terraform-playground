provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_iam_group" "chap3-1-iam-group" {
  name = "my-iam-group"
  path = "/"
}

resource "aws_iam_group_policy" "chap3-1-iam-group-policy" {
  name = "${aws_iam_group.chap3-1-iam-group.name}"
  group = "${aws_iam_group.chap3-1-iam-group.id}"
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

resource "aws_iam_user" "chap3-1-iam-user" {
  name = "chap3-1-iam-user"
}

resource "aws_iam_group_membership" "chap3-1-iam-membership" {
  name = "chap3-1-iam-membership"
  users = [
    "${aws_iam_user.chap3-1-iam-user.name}"
  ]
  group = "${aws_iam_group.chap3-1-iam-group.name}"
}

resource "aws_vpc" "chap3-1-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "vpc-WordPress"
  }
}

resource "aws_subnet" "chap3-1-public-a" {
  vpc_id = "${aws_vpc.chap3-1-vpc.id}"
  cidr_block = "10.0.11.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags {
    Name = "WP-PublicSubnet-A"
  }
}
resource "aws_subnet" "chap3-1-private-a" {
  vpc_id = "${aws_vpc.chap3-1-vpc.id}"
  cidr_block = "10.0.15.0/24"
  availability_zone = "ap-northeast-1a"
  tags {
    Name = "WP-PrivateSubnet-A"
  }
}
resource "aws_subnet" "chap3-1-public-c" {
  vpc_id = "${aws_vpc.chap3-1-vpc.id}"
  cidr_block = "10.0.51.0/24"
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "WP-PublicSubnet-C"
  }
}
resource "aws_subnet" "chap3-1-private-c" {
  vpc_id = "${aws_vpc.chap3-1-vpc.id}"
  cidr_block = "10.0.55.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags {
    Name = "WP-PrivateSubnet-C"
  }
}

resource "aws_internet_gateway" "chap3-1-igw" {
  vpc_id = "${aws_vpc.chap3-1-vpc.id}"
  tags {
    Name = "WP-InternetGateway"
  }
}

resource "aws_route_table" "chap3-1-public-rt" {
  vpc_id = "${aws_vpc.chap3-1-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.chap3-1-igw.id}"
  }
  tags {
    Name = "WP-PublicRoute"
  }
}

resource "aws_route_table_association" "chap3-1-public-assoc-a" {
  subnet_id = "${aws_subnet.chap3-1-public-a.id}"
  route_table_id = "${aws_route_table.chap3-1-public-rt.id}"
}
resource "aws_route_table_association" "chap3-1-public-assoc-c" {
  subnet_id = "${aws_subnet.chap3-1-public-c.id}"
  route_table_id = "${aws_route_table.chap3-1-public-rt.id}"
}

resource "aws_security_group" "chap3-1-web-sg" {
  name = "WP-Web-DMZ"
  description = "WordPress Web APP Security Group"
  vpc_id = "${aws_vpc.chap3-1-vpc.id}"
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
    security_groups = ["${aws_security_group.chap3-1-elb-sg.id}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = ["${aws_security_group.chap3-1-elb-sg.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "chap3-1-db-sg" {
  name = "WP-DB"
  description = "WordPress MySQL Security Group"
  vpc_id = "${aws_vpc.chap3-1-vpc.id}"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      "10.0.11.0/24",
      "10.0.51.0/24"
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "chap3-1-elb-sg" {
  name = "WP-ELB"
  description = "WordPress ELB Security Group"
  vpc_id = "${aws_vpc.chap3-1-vpc.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
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

resource "aws_db_instance" "chap3-1-rds" {
  identifier = "wp-mysql"
  allocated_storage = 5
  engine = "mysql"
  engine_version = "${var.aws_mysql_engine_version}"
  instance_class = "db.t2.micro"
  storage_type = "gp2"
  multi_az = true
  name = "wordpress"
  username = "${var.aws_db_username}"
  password = "${var.aws_db_password}"
  backup_retention_period = 1
  auto_minor_version_upgrade = true
  vpc_security_group_ids = [
    "${aws_security_group.chap3-1-db-sg.id}"
  ]
  db_subnet_group_name = "${aws_db_subnet_group.chap3-1-db-subnet-group.name}"
  provisioner "local-exec" {
    command = "echo rds_endpoint: ${aws_db_instance.chap3-1-rds.endpoint} > provisioner/config.yml"
  }
}

resource "aws_db_subnet_group" "chap3-1-db-subnet-group" {
  name = "wp-dbsubnet"
  description = "WordPress DB Subnet"
  subnet_ids = [
    "${aws_subnet.chap3-1-private-a.id}",
    "${aws_subnet.chap3-1-private-c.id}"
  ]
}

resource "aws_key_pair" "chap3-1-key" {
  key_name = "chap3-1-key"
  public_key = "${var.aws_public_key}"
}

resource "aws_instance" "chap3-1-ec2-a" {
  ami = "${var.aws_ami}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.chap3-1-web-sg.id}"
  ]
  subnet_id = "${aws_subnet.chap3-1-public-a.id}"
  associate_public_ip_address = true
  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }
  tags {
    Name = "WP-WebAPP"
  }
  key_name = "${aws_key_pair.chap3-1-key.key_name}"
  user_data = "${file("bin/bootstrap.sh")}"
}

resource "aws_instance" "chap3-1-ec2-c" {
  ami = "${var.aws_ami}"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.chap3-1-web-sg.id}"
  ]
  subnet_id = "${aws_subnet.chap3-1-public-c.id}"
  associate_public_ip_address = true
  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }
  tags {
    Name = "WP-WebAPP"
  }
  key_name = "${aws_key_pair.chap3-1-key.key_name}"
  user_data = "${file("bin/bootstrap.sh")}"
}

resource "aws_iam_server_certificate" "chap3-1-cert" {
  name = "WP-Self-Certificate-2015-3"
  certificate_body = "${file("certs/server.crt")}"
  private_key = "${file("certs/server.key")}"
}

resource "aws_elb" "chap3-1-elb" {
  name = "web-elb"
  subnets = [
    "${aws_subnet.chap3-1-public-a.id}",
    "${aws_subnet.chap3-1-public-c.id}"
  ]
  listener {
    instance_port = 443
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.chap3-1-cert.arn}"
  }
  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:443/index.html"
    interval = 30
  }
  instances = [
    "${aws_instance.chap3-1-ec2-a.id}",
    "${aws_instance.chap3-1-ec2-c.id}"
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 300
  security_groups = [
    "${aws_security_group.chap3-1-elb-sg.id}"
  ]
  tags {
    Name = "AWS_Book_ELB"
  }
}

resource "aws_lb_cookie_stickiness_policy" "chap3-1-elb-sticky" {
      name = "WP-ELB-Sticky"
      load_balancer = "${aws_elb.chap3-1-elb.id}"
      lb_port = 80
      cookie_expiration_period = 1800
}

output "ec2 a instance public ip" {
  value = "${aws_instance.chap3-1-ec2-a.public_ip}"
}
output "ec2 c instance public ip" {
  value = "${aws_instance.chap3-1-ec2-c.public_ip}"
}
output "rds endpoint" {
  value = "${aws_db_instance.chap3-1-rds.endpoint}"
}
output "elb dns name" {
  value = "${aws_elb.chap3-1-elb.dns_name}"
}
