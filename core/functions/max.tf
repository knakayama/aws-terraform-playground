output "max1" {
  value = "${max(-1, 0, 1)}"
}

output "max2" {
  value = "${max(-1, -2)}"
}
