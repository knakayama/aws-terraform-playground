variable "name"            { }
variable "region"          { }
variable "site_public_key" { }
variable "private_key"     { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "assume_role_policy"  { }
variable "role_policy"         { }

variable "vpc_cidr"      { }
variable "public_subnet" { }
variable "az"            { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name          = "${var.name}"
  az            = "${var.az}"
  vpc_cidr      = "${var.vpc_cidr}"
  public_subnet = "${var.public_subnet}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  region              = "${var.region}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  private_key         = "${var.private_key}"
  vpc_id              = "${module.network.vpc_id}"
  public_subnet_id    = "${module.network.public_subnet_id}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
  assume_role_policy  = "${file(var.assume_role_policy)}"
  role_policy         = "${var.role_policy}"
}

output "web_public_ip" { value = "${module.compute.web_public_ip}" }
