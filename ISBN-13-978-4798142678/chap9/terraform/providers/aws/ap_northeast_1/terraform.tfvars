# General
name   = "chap9-global"
region = "ap-northeast-1"

# Network
vpc_cidr        = "10.0.0.0/16"
azs             = "ap-northeast-1a,ap-northeast-1c"
public_subnet   = "10.0.0.0/24"
private_subnets = "10.0.1.0/24,10.0.2.0/24"

# Web
web_instance_type   = "t2.nano"
web_instance_ami_id = "ami-db4e7bb5"

# RDS
rds_username      = "wordpress"
rds_password      = "wordpress"
rds_engine        = "mysql"
rds_engine_ver    = "5.6.23"
rds_instance_type = "db.t2.micro"

# S3
acl         = "public-read"
policy_file = "policy.json.tpl"
htmls       = "index.html,error.html"

# Route53
domain    = "YOUR_DOMAIN_HERE"
wp_domain = "YOUR_WP_DOMAIN_HERE"
s3_domain = "YOUR_S3_DOMAIN_HERE"
