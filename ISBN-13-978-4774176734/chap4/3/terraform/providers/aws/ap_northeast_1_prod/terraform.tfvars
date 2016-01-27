# General
name   = "chap4-3-prod"
region = "ap-northeast-1"

# Network
vpc_cidr      = "172.16.0.0/16"
public_subnet = "172.16.0.0/24"

# S3
acl         = "public-read"
policy_file = "policy.json.tpl"
htmls       = "index.html,error.html"

# Web
web_instance_type   = "t2.nano"
web_instance_ami_id = "ami-383c1956"

# Route53
domain     = "YOUR_DOMAIN_HERE"
sub_domain = "YOUR_SUB_DOMAIN_HERE"
