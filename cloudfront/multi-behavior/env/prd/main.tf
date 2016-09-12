provider "aws" {
  region = "${var.region}"
}

module "iam" {
  source = "../../modules/iam"

  name = "${var.name}"
}

module "prd" {
  source = "../../"

  name                = "${var.name}"
  vpc_cidr            = "${var.vpc_cidr}"
  email_address       = "${var.email_address}"
  instance_types      = "${var.instance_types}"
  asg_config          = "${var.asg_config}"
  db_config           = "${var.db_config}"
  cf_config           = "${var.cf_config}"
  elasticache_config  = "${var.elasticache_config}"
  azs                 = "${data.aws_availability_zones.az.names}"
  amazon_linux_id     = "${data.aws_ami.amazon_linux.id}"
  instance_profile_id = "${module.iam.instance_profile_id}"
  domain_config       = "${var.domain_config}"
}

module "dns" {
  source = "../../modules/dns"

  domain_config     = "${var.domain_config}"
  bastion_public_ip = "${module.prd.bastion_public_ip}"
  elb_config        = "${module.prd.elb_config}"
  cf_config         = "${module.prd.cf_config}"
}
