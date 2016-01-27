# General
name       = "chap5-2-prod"
region     = "ap-northeast-1"

# Network
vpc_cidr      = "172.16.0.0/16"
az            = "ap-northeast-1a"
public_subnet = "172.16.0.0/24"

# Web
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-d47342ba"
