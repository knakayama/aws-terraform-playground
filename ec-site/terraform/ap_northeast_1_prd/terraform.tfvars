# General
name = "prd-ec-site"

region = "ap-northeast-1"

keypair = "site_key.pub"

# Network
vpc_cidr = "172.16.0.0/16"

azs = "ap-northeast-1a,ap-northeast-1c"

public_subnets = "172.16.0.0/24,172.16.1.0/24"

private_subnets_web = "172.16.2.0/24,172.16.3.0/24"

private_subnets_db = "172.16.4.0/24,172.16.5.0/24"

# Compute
web_ap_admin_type = "t2.nano"

web_ap_admin_ami_id = "ami-29160d47"

web_ap_public_type = "t2.nano"

web_ap_public_ami_id = "ami-29160d47"

web_ap_public_max_size = "2"

web_ap_public_min_size = "1"

# DB
rds_db_name = "aurora"

rds_master_username = "aurora"

rds_master_password = "pAssw0rd"

rds_class = "db.r3.large"

# ElastiCache
elasticache_engine = "memcached"

elasticache_engine_ver = "1.4.24"

elasticache_type = "cache.t2.micro"

# DNS
public_domain = "YOUR_DOMAIN"

private_domain = "YOUR_LOCAL_DOMAIN"

web_ap_admin_sub_domain = "web-ap-admin"

web_ap_public_sub_domain = "web-ap-public"

rds_sub_domain = "db"

elasticache_sub_domain = "cache"
