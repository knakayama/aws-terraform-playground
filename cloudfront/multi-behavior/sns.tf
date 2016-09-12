module "tf_sns_email" {
  source = "github.com/deanwilson/tf_sns_email"

  display_name  = "${var.name}"
  email_address = "${var.email_address}"
  owner         = "me"
  stack_name    = "${replace(var.name, "_", "-")}"
}
