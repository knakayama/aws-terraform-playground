data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "es" {
  statement {
    effect = "Allow"

    actions = [
      "es:*",
    ]

    resources = [
      "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.es_config["domain"]}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = [
        "${var.es_config["ip"]}",
      ]
    }

    principals = {
      type = "AWS"

      identifiers = [
        "*",
      ]
    }
  }
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.es_config["domain"]}"
  elasticsearch_version = "${var.es_config["version"]}"
  access_policies       = "${data.aws_iam_policy_document.es.json}"

  cluster_config {
    instance_type = "${var.es_config["type"]}"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "${var.es_config["size"]}"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = false
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    Domain = "${var.name}"
  }
}
