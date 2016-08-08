variable "name"           { default = "iam" }
variable "users"          { }
variable "managed_policy" { }

resource "aws_iam_group" "mod" {
  name = "${var.name}"
}

resource "aws_iam_user" "mod" {
  count = "${length(split(",", var.users))}"
  name  = "${element(split(",", var.users), count.index)}"
}

resource "aws_iam_access_key" "mod" {
  count = "${length(split(",", var.users))}"
  user  = "${element(aws_iam_user.mod.*.name, count.index)}"
}

resource "aws_iam_group_membership" "mod" {
  name  = "${var.name}"
  group = "${aws_iam_group.mod.name}"
  users = ["${aws_iam_user.mod.*.name}"]
}

resource "aws_iam_policy_attachment" "mod" {
  name       = "${var.name}"
  groups     = ["${aws_iam_group.mod.name}"]
  policy_arn = "${var.managed_policy}"
}

output "users"       { value = "${join(",", aws_iam_access_key.mod.*.user)}" }
output "access_ids"  { value = "${join(",", aws_iam_access_key.mod.*.id)}" }
output "secret_keys" { value = "${join(",", aws_iam_access_key.mod.*.secret)}" }
