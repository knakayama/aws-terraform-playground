# General
name       = "chap5-4-prod"
region     = "ap-northeast-1"
account_id = "804256469719"

# Network
vpc_cidrs      = "172.16.0.0/16,172.17.0.0/16"
azs            = "ap-northeast-1a,ap-northeast-1c"
public_subnets = "172.16.0.0/24,172.17.0.0/24"

# Web
web_instance_type   = "t2.nano"
web_instance_ami_id = "ami-383c1956"

# DNS
domain      = "YOUR_DOMAIN_HERE"
sub_domains = "YOUR_SUB_DOMAINS_HERE"
