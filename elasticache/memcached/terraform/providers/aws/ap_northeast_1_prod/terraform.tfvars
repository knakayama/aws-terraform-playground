# General
name   = "elasticache-memcached"
region = "ap-northeast-1"

# Network
vpc_cidr        = "172.16.0.0/16"
azs             = "ap-northeast-1a,ap-northeast-1c"
public_subnets  = "172.16.0.0/24,172.16.1.0/24"
private_subnets = "172.16.2.0/24,172.16.3.0/24"

# EC2
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-b51710db"

# RDS
rds_username      = "wordpress"
rds_password      = "wordpress"
rds_engine        = "mysql"
rds_engine_ver    = "5.6.23"
rds_instance_type = "db.t2.micro"

# Route53
domain     = "knakayama.io"
sub_domain = "wp"

# ElastiCache
elasticache_engine     = "memcached"
elasticache_engine_ver = "1.4.24"
elasticache_node_type  = "cache3.t2.micro"
