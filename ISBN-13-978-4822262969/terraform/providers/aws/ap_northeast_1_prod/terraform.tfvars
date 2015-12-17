# General
name   = "prod"
region = "ap-northeast-1"

# Network
vpc_cidr        = "10.0.0.0/16"
azs             = "ap-northeast-1a,ap-northeast-1c"
public_subnets  = "10.0.1.0/24"
private_subnets = "10.0.2.0/24"

# Bastion
bastion_instance_type   = "t2.micro"
bastion_instance_ami_id = "ami-7fb39911"

# NAT
nat_instance_type   = "t2.micro"
nat_instance_ami_id = "ami-03cf3903"

# MySQL
mysql_instance_type   = "t2.micro"
mysql_instance_ami_id = "ami-aeb69cc0"
