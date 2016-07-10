resource "aws_iam_role" "fleet_role" {
  name               = "fleet-role"
  assume_role_policy = "${file("assume_role_policy.json")}"
}

resource "aws_iam_policy_attachment" "fleet_role" {
  name       = "EC2SpotFleetRole"
  roles      = ["${aws_iam_role.fleet_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole"
}
