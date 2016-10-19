variable "region" {
  default = "ap-northeast-1"
}

variable "env" {
  default = [
    "dev",
    "prd",
  ]
}

variable "vpc_cidrs" {
  default = {
    dev = "172.16.0.0/16"
    prd = "172.17.0.0/16"
  }
}
