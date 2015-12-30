variable "name"               { }
variable "vpc_id"             { }
variable "key_name"           { }
variable "public_subnet_ids"  { }
variable "lc_instance_type"   { }
variable "lc_instance_ami_id" { }
variable "desired_capacity"   { }
variable "max_size"           { }
variable "min_size"           { }

module "web" {
  source = "./web"

  name              = "${var.name}"
  vpc_id            = "${var.vpc_id}"
  key_name          = "${var.key_name}"
  public_subnet_ids = "${var.public_subnet_ids}"
  instance_type     = "${var.lc_instance_type}"
  instance_ami_id   = "${var.lc_instance_ami_id}"
  desired_capacity  = "${var.desired_capacity}"
  max_size          = "${var.max_size}"
  min_size          = "${var.min_size}"
}
