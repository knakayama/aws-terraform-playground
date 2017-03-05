provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
