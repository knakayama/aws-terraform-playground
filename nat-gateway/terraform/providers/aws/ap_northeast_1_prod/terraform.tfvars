# General
name   = "nat-gateway"
region = "ap-northeast-1"

# Network
vpc_cidr       = "10.0.0.0/16"
azs            = "ap-northeast-1a,ap-northeast-1c"
public_subnet  = "10.0.1.0/24"
private_subnet = "10.0.2.0/24"

# EC2
ec2_instance_type   = "t2.micro"
ec2_instance_ami_id = "ami-383c1956"
