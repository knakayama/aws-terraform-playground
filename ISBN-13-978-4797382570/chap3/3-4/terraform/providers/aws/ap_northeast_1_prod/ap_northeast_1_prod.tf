variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "lc_instance_type"   { }
variable "lc_instance_ami_id" { }

variable "vpc_cidr"       { }
variable "public_subnets" { }
variable "azs"            { }

variable "lc_instance_type"   { }
variable "lc_instance_ami_id" { }

variable "max_size"         { }
variable "min_size"         { }
variable "desired_capacity" { }

provider "aws" {
  region     = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name           = "${var.name}"
  azs            = "${var.azs}"
  vpc_cidr       = "${var.vpc_cidr}"
  public_subnets = "${var.public_subnets}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name               = "${var.name}"
  key_name           = "${aws_key_pair.site_key.key_name}"
  vpc_id             = "${module.network.vpc_id}"
  public_subnet_ids  = "${module.network.public_subnet_ids}"
  lc_instance_type   = "${var.lc_instance_type}"
  lc_instance_ami_id = "${var.lc_instance_ami_id}"
  max_size           = "${var.max_size}"
  min_size           = "${var.min_size}"
  desired_capacity   = "${var.desired_capacity}"
}
