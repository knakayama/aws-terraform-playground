resource "aws_iam_role" "asg" {
  name               = "${var.name}-asg-role"
  assume_role_policy = "${file("${path.module}/policies/asg_assume_role_policy.json")}"
}

resource "aws_iam_instance_profile" "asg" {
  name  = "${var.name}-asg-role"
  roles = ["${aws_iam_role.asg.name}"]
}

resource "aws_iam_policy_attachment" "asg" {
  name       = "EC2FullAccess"
  roles      = ["${aws_iam_role.asg.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
