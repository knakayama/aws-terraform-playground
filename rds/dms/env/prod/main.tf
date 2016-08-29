provider "aws" {
  region = "${var.region}"
}

module "main" {
  source = "../.."

  name              = "${var.name}"
  azs               = "${data.aws_availability_zones.az.names}"
  vpc_cidr          = "${var.vpc_cidr}"
  amazon_linux_id   = "${data.aws_ami.amazon_linux.id}"
  web_instance_type = "${var.web_instance_type}"
  cnt               = "${var.cnt}"
  account_id        = "${data.aws_caller_identity.current.account_id}"
}
