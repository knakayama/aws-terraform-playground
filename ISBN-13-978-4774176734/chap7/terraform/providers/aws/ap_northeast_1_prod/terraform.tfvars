# General
name   = "chap7-global"
region = "ap-northeast-1"

# Network
vpc_cidr       = "10.0.0.0/16"
azs            = "ap-northeast-1a,ap-northeast-1c"
public_subnets = "10.0.0.0/24,10.0.1.0/24"

# RDS
rds_username      = "wordpress"
rds_password      = "wordpress"
rds_engine        = "mysql"
rds_engine_ver    = "5.6.23"
rds_instance_type = "db.t2.micro"
rds_family        = "mysql5.6"

# Route53
domain     = "YOUR_DOMAIN_HERE"
sub_domain = "YOUR_SUB_DOMAIN_HERE"
