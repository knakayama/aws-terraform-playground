output "rds_endpoint" {
  value = "${aws_db_instance.rds.endpoint}"
}

output "nginx_config" {
  value = <<EOT

location /ping {
    if (-f "/dev/shm/ok.txt") {
        return 200;
    }
    proxy_pass http://${aws_elb.elb.dns_name}/check-db
}
EOT
}

output "health_check_script" {
  value = <<EOT

#!/usr/bin/env bash

INSTANCE_ID="$(/usr/bin/curl http://169.254.169.254/latest/meta-data/instance-id)"
ELB="${aws_elb.elb.name}"

/usr/bin/aws elb describe-instance-health \
  --load-balancer-name "$ELB" \
  --instances "$INSTANCE_ID" \
  --region "ap-northeast-1" \
  | /bin/grep -qF 'InService' \
  || exit 1

/bin/touch "/dev/shm/ok.txt"
EOT
}
