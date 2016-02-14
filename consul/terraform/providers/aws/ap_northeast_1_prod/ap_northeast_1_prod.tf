variable "name"            { }
variable "region"          { }
variable "account_id"      { }
variable "site_public_key" { }
variable "key_path"        { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "web_platform"        { }

variable "vpc_cidrs"      { }
variable "public_subnets" { }
variable "azs"            { }

variable "domain"      { }
variable "sub_domains" { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file(concat(path.module, "/", var.site_public_key))}"
}

module "network" {
  source = "../../../modules/aws/network"

  name           = "${var.name}"
  azs            = "${var.azs}"
  vpc_cidrs      = "${var.vpc_cidrs}"
  account_id     = "${var.account_id}"
  public_subnets = "${var.public_subnets}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  region              = "${var.region}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  key_file            = "${file(concat(path.module, "/", var.key_path))}"
  vpc_ids             = "${module.network.vpc_ids}"
  azs                 = "${var.azs}"
  public_subnet_ids   = "${module.network.public_subnet_ids}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
  web_platform        = "${var.web_platform}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  domain          = "${var.domain}"
  sub_domains     = "${var.sub_domains}"
  vpc_ids         = "${module.network.vpc_ids}"
  web_private_ips = "${module.compute.web_private_ips}"
}

output "web_public_ips"  { value = "${module.compute.web_public_ips}" }
output "web_private_ips" { value = "${module.compute.web_private_ips}" }
output "web_fqdns"       { value = "${module.dns.web_fqdns}" }
