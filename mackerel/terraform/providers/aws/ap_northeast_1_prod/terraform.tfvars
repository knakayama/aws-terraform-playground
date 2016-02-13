# General
name            = "aws-mackerel-demo"
region          = "ap-northeast-1"
site_public_key = "keys/aws.pem.pub"

# Network
vpc_cidr      = "172.16.0.0/16"
az            = "ap-northeast-1a"
public_subnet = "172.16.0.0/24"

# Compute
web_instance_type   = "t2.micro"
web_instance_ami_id = "ami-29f7c947"

# Domain
domain     = "knakayama.io"
sub_domain = "mackrel"
