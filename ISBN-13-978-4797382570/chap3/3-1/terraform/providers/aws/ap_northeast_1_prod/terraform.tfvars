# General
name   = "chap3-3-1-prod"
region = "ap-northeast-1"

# Network
vpc_cidr        = "10.0.0.0/16"
azs             = "ap-northeast-1a,ap-northeast-1c"
public_subnets  = "10.0.11.0/24,10.0.51.0/24"
private_subnets = "10.0.15.0/24,10.0.55.0/24"

# Compute
web_instance_type   = "t2.nano"
web_instance_ami_id = "ami-db4e7bb5"

rds_username      = "wordpress"
rds_password      = "wordpress"
rds_engine        = "mysql"
rds_engine_ver    = "5.6.23"
rds_instance_type = "db.t2.micro"
