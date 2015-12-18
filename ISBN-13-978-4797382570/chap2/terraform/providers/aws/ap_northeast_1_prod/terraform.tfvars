# General
name   = "chap2-prod"
region = "ap-northeast-1"

# Network
vpc_cidr       = "10.0.0.0/16"
azs            = "ap-northeast-1a,ap-northeast-1c"
public_subnets = "10.0.0.0/24,10.0.1.0/24"

# Compute
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-383c1956"
