variable "name"            { }
variable "web_instance_id" { }
variable "rds_instance_id" { }
variable "s3_bucket_id"    { }

module "sns" {
  source = "./sns"

  name         = "${var.name}-sns"
}

module "cloudwatch" {
  source = "./cloudwatch"

  name                       = "${var.name}-cloudwatch"
  sns_topic_subscription_arn = "${module.sns.topic_subscription_arn}"
  web_instance_id            = "${var.web_instance_id}"
  rds_instance_id            = "${var.rds_instance_id}"
  s3_bucket_id               = "${var.s3_bucket_id}"
}
