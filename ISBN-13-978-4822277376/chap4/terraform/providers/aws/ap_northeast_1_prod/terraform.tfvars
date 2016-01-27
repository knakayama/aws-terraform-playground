# General
name   = "chap4-prod"
region = "ap-northeast-1"

# Network
azs             = "ap-northeast-1a,ap-northeast-1c"
vpc_cidr        = "172.16.0.0/16"
public_subnets  = "172.16.0.0/24,172.16.1.0/24"
private_subnets = "172.16.2.0/24,172.16.3.0/24"

# Web
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-383c1956"

# RDS
rds_username      = "eccube_db_user"
rds_password      = "eccubepasswd"
rds_engine        = "mysql"
rds_engine_ver    = "5.6.23"
rds_instance_type = "db.t2.micro"
rds_family        = "mysql5.6"

# Route53
domain     = "YOUR_DOMAIN_HERE"
sub_domain = "ec"
