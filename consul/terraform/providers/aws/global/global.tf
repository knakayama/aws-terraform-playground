variable "name"       { }
variable "region"     { }
variable "iam_admins" { }
variable "policy"     { }

provider "aws" {
  region = "${var.region}"
}

module "iam_admin" {
  source = "../../../modules/aws/util/iam"

  name   = "${var.name}-admin"
  users  = "${var.iam_admins}"
  policy = "${file(var.policy)}"
}

output "iam_admin_users"       { value = "${module.iam_admin.users}" }
output "iam_admin_access_ids"  { value = "${module.iam_admin.access_ids}" }
output "iam_admin_secret_keys" { value = "${module.iam_admin.secret_keys}" }
