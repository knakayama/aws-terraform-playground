# General
name   = "chap3-3-3-1-prod"
region = "ap-northeast-1"

# S3
acl         = "public-read"
policy_file = "policy.json.tpl"
htmls       = "index.html,error.html"

# Route53
domain     = "YOUR_DOMAIN_HERE"
sub_domain = "YOUR_SUB_DOMAIN_HERE"
