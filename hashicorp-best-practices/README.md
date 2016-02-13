hashicorp/best-practices
========================

[hashicorp/best-practices](https://github.com/hashicorp/best-practices)の内容を勉強する。

## memo

### 全体像

todo

### Setup

#### Environment Variables

ローカルで動作させるためには以下の環境変数を設定する

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* AWS_DEFAULT_REGION=ap-northeast-1
* ATLAS_USERNAME
* ATLAS_TOKEN

#### Generate Keys and Certs

```bash
$ cd setup
# General site key
$ sh ./gen_key.sh site
$ mv -i site* ../keys
# Generate site and vault certs
$ sh ./gen_cert.sh _YOUR_DOMAIN_ _YOUR_COMPANY_
$ mv -i site* vault* ../keys/
```

#### Build Configuration

`base` となるものとそれを利用するものをそれぞれ作る

Go [New Build Configuration](https://atlas.hashicorp.com/builds/new), leave **Automatically build on version uploads** and **Connect build configuration to a GitHub repository** boxes _unchecked_.

`base` 以外は **Inject artifact ID during build** をつくる

|Name                             |Packer directory              |Packer template        |Environments                                                                         |
|---------------------------------|------------------------------|-----------------------|-------------------------------------------------------------------------------------|
|aws-ap-northeast-1-ubuntu-base   |hashicor-best-practices/packer|aws/ubuntu/base.json   |ATLAS_USERNAME<br/>AWS_ACCESS_KEY_ID<br/>AWS_SECRET_ACCESS_KEY<br/>AWS_DEFAULT_REGION|
|aws-ap-northeast-1-ubuntu-consul |hashicor-best-practices/packer|aws/ubuntu/consul.json |same as above                                                                        |
|aws-ap-northeast-1-ubuntu-vault  |hashicor-best-practices/packer|aws/ubuntu/vault.json  |same as above                                                                        |
|aws-ap-northeast-1-ubuntu-haproxy|hashicor-best-practices/packer|aws/ubuntu/haproxy.json|same as above                                                                        |
|aws-ap-northeast-1-ubuntu-nodejs |hashicor-best-practices/packer|aws/ubuntu/nodejs.json |same as above                                                                        |

### `packer/aws/ubuntu/base.json`

```json
"run_tags":        { "ami-create": "{{user `ap_northeast_1_name`}}" },
```

### `terraform/providers/aws/global/global.tf`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:PutUserPolicy",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:DeleteAccessKey",
        "iam:DeleteUserPolicy",
        "iam:RemoveUserFromGroup",
        "iam:DeleteUser"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```

### `terraform/providers/aws/ap_northeast_1_prod/ap_northeast_1_prod.tf`

#### `atlas` block

https://www.terraform.io/docs/configuration/atlas.html

```hcl
atlas {
  name = "${var.atlas_username}/${var.atlas_environment}"
}
```

```hcl
route_zone_id     = "${terraform_remote_state.aws_global.output.zone_id}"
```

#### `terraform_remote_state` resource

http://qiita.com/atsaki/items/d4678c1d62093fef47ec

```hcl
resource "terraform_remote_state" "aws_global" {
  backend = "atlas"

  config {
    name = "${var.atlas_username}/${var.atlas_aws_global}"
  }

  lifecycle { create_before_destroy = true }
}
```

#### ephemeral_subnets

```hcl
# The reason for this is that ephemeral nodes (nodes that are recycled often like ASG nodes),
# need to be in separate subnets from long-running nodes (like Elasticache and RDS) because
# AWS maintains an ARP cache with a semi-long expiration time.

# So if node A with IP 10.0.0.123 gets terminated, and node B comes in and picks up 10.0.0.123
# in a relatively short period of time, the stale ARP cache entry will still be there,
# so traffic will just fail to reach the new node.
module "ephemeral_subnets" {
  source = "./private_subnet"

  name   = "${var.name}-ephemeral"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${var.ephemeral_subnets}"
  azs    = "${var.azs}"

  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}
```
