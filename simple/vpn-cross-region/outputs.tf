output "oregon" {
  value = <<EOT

EC2-1:

public ip:  ${aws_instance.ec2_oregon.0.public_ip}
private ip: ${aws_instance.ec2_oregon.0.private_ip}

EC2-2:
public ip:  ${aws_instance.ec2_oregon.1.public_ip}
private ip: ${aws_instance.ec2_oregon.1.private_ip}
EOT
}

output "tokyo" {
  value = <<EOT

VyOS:

public ip:  ${aws_instance.vyos_tokyo.public_ip}
private ip: ${aws_instance.vyos_tokyo.private_ip}

EC2:
public ip:  ${aws_instance.ec2_tokyo.public_ip}
private ip: ${aws_instance.ec2_tokyo.private_ip}
EOT
}
