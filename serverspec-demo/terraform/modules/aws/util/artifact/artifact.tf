variable "type"             { default = "amazon.ami" }
variable "region"           { }
variable "atlas_username"   { }
variable "artifact_name"    { }
variable "artifact_version" { default = "latest" }

resource "atlas_artifact" "artifact" {
  name    = "${var.atlas_username}/${var.artifact_name}"
  type    = "${var.type}"
  version = "${var.artifact_version}"

  lifecycle { create_before_destroy = true }
  metadata  { region = "${var.region}" }
}

output "id" { value = "${atlas_artifact.artifact.metadata_full.region-ap-northeast-1}" }
