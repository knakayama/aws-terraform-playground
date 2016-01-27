# General
name       = "chap3-4-prod"
region     = "ap-northeast-1"

# Network
vpc_cidr       = "172.16.0.0/16"
azs            = "ap-northeast-1a,ap-northeast-1c"
public_subnets = "172.16.0.0/24,172.16.1.0/24"

# Launch Configuration
lc_instance_type   = "t2.micro"
lc_instance_ami_id = "ami-383c1956"

# AutoScaling
max_size         = 8
min_size         = 2
desired_capacity = 2
