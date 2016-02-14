# General
name              = "aws-consul-demo"
region            = "ap-northeast-1"
atlas_environment = "REPLACE_IN_ATLAS"
atlas_aws_global  = "REPLACE_IN_ATLAS"
atlas_token       = "REPLACE_IN_ATLAS"
atlas_username    = "REPLACE_IN_ATLAS"
site_public_key   = "REPLACE_IN_ATLAS"
site_private_key  = "REPLACE_IN_ATLAS"

# Network
vpc_cidrs      = "172.16.0.0/16,172.17.0.0/16"
azs            = "ap-northeast-1a,ap-northeast-1c"
public_subnets = "172.16.0.0/24,172.17.0.0/24"

# Web
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-01675e6f"
web_platform        = "Amazon_Linux"

# DNS
domain      = "knakayama.io"
sub_domains = "node1,node2"
