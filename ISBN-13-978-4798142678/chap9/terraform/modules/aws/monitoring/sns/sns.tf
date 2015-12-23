variable "name"         { default = "monitoring" }

resource "aws_sqs_queue" "sns" {
  name = "${var.name}"
}

resource "aws_sns_topic" "sns" {
  name = "${var.name}"
}

resource "aws_sns_topic_subscription" "sns" {
  topic_arn = "${aws_sns_topic.sns.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.sns.arn}"
}

output "topic_subscription_arn" { value = "${aws_sns_topic_subscription.sns.arn}" }
