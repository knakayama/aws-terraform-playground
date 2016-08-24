resource "aws_iam_role" "ec2_role" {
  name               = "${var.name}-ec2-role"
  assume_role_policy = "${file("${path.module}/policies/ec2_assume_role_policy.json")}"
}

resource "aws_iam_policy_attachment" "cloudwatch_full_access" {
  name       = "CloudWatchFullAccess"
  roles      = ["${aws_iam_role.ec2_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name  = "${var.name}-instance-profile"
  roles = ["${aws_iam_role.ec2_role.name}"]
}
