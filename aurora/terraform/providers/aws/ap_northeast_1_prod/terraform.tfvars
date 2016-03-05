# General
name              = "aurora"
region            = "ap-northeast-1"
site_public_key   = "REPLACE_IN_ATLAS"
atlas_environment = "REPLACE_IN_ATLAS"
atlas_aws_global  = "REPLACE_IN_ATLAS"
atlas_token       = "REPLACE_IN_ATLAS"
atlas_username    = "REPLACE_IN_ATLAS"

# Network
vpc_cidr        = "172.16.0.0/16"
azs             = "ap-northeast-1a,ap-northeast-1c"
public_subnets  = "172.16.0.0/24,172.16.2.0/24"
private_subnets = "172.16.1.0/24,172.16.3.0/24"

# Compute
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-383c1956"

# RDS
rds_database_name   = "aurora"
rds_master_username = "aurora"
rds_master_password = "pAssw0rd"
rds_instance_class  = "db.r3.large"
