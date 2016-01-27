# General
name   = "chap6-global"
region = "ap-northeast-1"

# Network
vpc_cidr      = "10.0.0.0/16"
az            = "ap-northeast-1a"
public_subnet = "10.0.11.0/24"

# Web
web_instance_type   = "t1.micro"
web_instance_ami_id = "ami-a06e42ce"

# S3
acl         = "public-read"
policy_file = "policy.json.tpl"
htmls       = "index.html,error.html"

# Route53
domain    = "YOUR_DOMAIN_HERE"
mt_domain = "YOUR_MT_DOMAIN_HERE"
s3_domain = "YOUR_S3_DOMAIN_HERE"
