resource "aws_vpc" "vpc" {
  cidr_block           = "${terraform.env == "dev" ? var.dev_network_config["vpc_cidr"] : var.prod_network_config["vpc_cidr"]}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}-${terraform.env}-vpc"
  }
}
