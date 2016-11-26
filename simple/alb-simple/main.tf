provider "aws" {
  region = "${var.regions["tokyo"]}"
}

provider "aws" {
  alias  = "virginia"
  region = "${var.regions["virginia"]}"
}
