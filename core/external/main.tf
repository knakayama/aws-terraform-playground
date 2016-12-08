variable "domain" {}

provider "aws" {
  region = "ap-northeast-1"
}

data "external" "hosted_zone_id" {
  program = ["bash", "${path.module}/list-hosted-zone-by-name.sh"]

  query = {
    domain = "${var.domain}"
  }
}

data "external" "resource_record_sets" {
  program = ["bash", "${path.module}/list-resource-record-sets.sh"]

  query = {
    hosted_zone_id = "${replace(data.external.hosted_zone_id.result["HostedZoneId"], "//hostedzone//", "")}"
  }
}

output "resource_record_sets" {
  value = "${data.external.resource_record_sets.result}"
}
