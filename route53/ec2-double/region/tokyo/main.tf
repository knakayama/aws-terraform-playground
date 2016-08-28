provider "aws" {
  region = "${var.region}"
}

module "tokyo" {
  source = "../.."

  name              = "${var.name}"
  vpc_cidr          = "${var.vpc_cidr}"
  web_instance_type = "${var.web_instance_type}"
  azs               = "${data.aws_availability_zones.az.names}"
  amazon_linux_id   = "${data.aws_ami.amazon_linux.id}"
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  name          = "${var.name}"
  domain_config = "${var.domain_config}"
  cf_config     = "${var.cf_config}"
  elb_dns_name  = "${module.tokyo.elb_dns_name}"
  elb_id        = "${module.tokyo.elb_id}"
}
