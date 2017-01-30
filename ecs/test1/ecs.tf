resource "aws_ecr_repository" "test" {
  name = "${var.env}"
}

resource "aws_ecr_repository_policy" "test" {
  repository = "${aws_ecr_repository.test.name}"
  policy     = "${data.aws_iam_policy_document.ecr.json}"
}
