variable "name"   { default = "iam" }
variable "users"  {}
variable "policy" {}

resource "aws_iam_group" "chap2-mod" {
  count = "${length(split(",", var.users))}"
  name  = "${element(split(",", var.users), count.index)}"
}

resource "aws_iam_group_policy" "chap2-mod" {
  name   = "${aws_iam_group.chap2-mod.name}"
  group  = "${aws_iam_group.chap2-mod.id}"
  policy = "${var.policy}"
}

resource "aws_iam_user" "chap2-mod" {
  count = "${length(split(",", var.users))}"
  name  = "${element(split(",", var.users), count.index)}"
}

resource "aws_iam_access_key" "chap2-mod" {
  count = "${length(split(",", var.users))}"
  user  = "${element(aws_iam_user.chap2-mod.*.name, count.index)}"
}

resource "aws_iam_group_membership" "chap2-mod" {
  name = "${var.name}"
  group = "${aws_iam_group.chap2-mod.name}"
  users = ["${aws_iam_user.chap2-mod.*.name}"]
}

output "users"       { value = "${join(",", aws_iam_access_key.chap2-mod.*.user)}" }
output "access_ids"  { value = "${join(",", aws_iam_access_key.chap2-mod.*.id)}" }
output "secret_keys" { value = "${join(",", aws_iam_access_key.chap2-mod.*.secret)}" }
