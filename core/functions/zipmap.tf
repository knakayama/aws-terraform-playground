variable "list1" {
  default = ["key"]
}

variable "list2" {
  default = ["value"]
}

output "zipmap1" {
  value = "${zipmap(var.list1, var.list2)}"
}
