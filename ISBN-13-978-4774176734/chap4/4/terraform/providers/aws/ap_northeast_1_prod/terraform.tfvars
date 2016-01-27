# General
name   = "chap4-5-prod"
region = "ap-northeast-1"

# Network
vpc_cidr       = "172.16.0.0/16"
azs            = "ap-northeast-1a,ap-northeast-1c"
public_subnets = "172.16.0.0/24,172.16.1.0/24"

# Web
web_instance_type   = "t2.nano"
web_instance_ami_id = "ami-383c1956"

# Route53
domain      = "YOUR_DOMAIN_HERE"
sub_domains = "YOUR_SUB_DOMAIN_HERE"
