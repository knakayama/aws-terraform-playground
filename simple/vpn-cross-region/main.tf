provider "aws" {
  region = "${var.regions["tokyo"]}"
}

provider "aws" {
  alias  = "oregon"
  region = "${var.regions["oregon"]}"
}
