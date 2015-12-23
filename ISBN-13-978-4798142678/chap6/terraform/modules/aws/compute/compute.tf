variable name                { }
variable vpc_id              { }
variable public_subnet_id    { }
variable key_name            { }
variable web_instance_type   { }
variable web_instance_ami_id { }

module "web" {
  source = "./web"

  name             = "${var.name}-web"
  vpc_id           = "${var.vpc_id}"
  public_subnet_id = "${var.public_subnet_id}"
  key_name         = "${var.key_name}"
  instance_type    = "${var.web_instance_type}"
  instance_ami_id  = "${var.web_instance_ami_id}"
}

output "web_public_ip" { value = "${module.web.public_ip}" }
