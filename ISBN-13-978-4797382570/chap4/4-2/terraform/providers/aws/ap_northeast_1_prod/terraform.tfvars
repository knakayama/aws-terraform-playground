# General
name   = "chap4-4-3-prod"
region = "ap-northeast-1"

# Network
vpc_cidr      = "172.16.0.0/16"
az            = "ap-northeast-1a"
public_subnet = "172.16.0.0/24"

# Web
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-383c1956"
assume_role_policy  = "assume_role_policy.json"
role_policy         = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
