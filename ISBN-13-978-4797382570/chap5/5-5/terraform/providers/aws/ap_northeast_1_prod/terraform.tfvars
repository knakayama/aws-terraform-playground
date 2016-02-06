# General
name   = "chap5-5-5-prod"
region = "ap-northeast-1"

# Network
azs            = "ap-northeast-1a,ap-northeast-1c"
vpc_cidr       = "172.16.0.0/16"
public_subnets = "172.16.0.0/24,172.16.1.0/24"

# Web
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-383c1956"

# Route53
domain     = "knakayama.io"
sub_domain = "wp"

# AutoScale
max_size = 2
min_size = 1
