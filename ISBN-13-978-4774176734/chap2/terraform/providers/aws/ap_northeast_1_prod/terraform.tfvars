# General
name   = "chap2-prod"
region = "ap-northeast-1"

# Network
vpc_cidr       = "172.16.0.0/16"
azs            = "ap-northeast-1"
public_subnets = "172.16.0.0/24"

# Web
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-c08ea4ae"
