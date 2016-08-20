output "ec2_public_ip" {
  value = "${aws_instance.ec2.public_ip}"
}

#output "cache_node_addresses" {


#  value = "${join(", ", aws_elasticache_cluster.redis.*.address)}"


#}

