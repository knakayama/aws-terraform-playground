hashicorp/best-practices
========================

My study aboud [hashicorp/best-practices](https://github.com/hashicorp/best-practices). See LICENSE.

## 全体像

todo

## Setup

### Environment Variables

ローカルで動作させたい場合は以下の環境変数を設定する

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* AWS_DEFAULT_REGION=ap-northeast-1
* ATLAS_USERNAME
* ATLAS_TOKEN

### Generate Keys and Certs

```bash
$ cd setup
# General site key
$ sh ./gen_key.sh site
$ mv -i site* ../keys
# Generate site and vault certs
$ sh ./gen_cert.sh _YOUR_DOMAIN_ _YOUR_COMPANY_
$ mv -i site* vault* ../keys/
```

### Build Configuration

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

### Deploy a `ap-northeast-1` Node.js Application

1. Fork the [`demo-app-nodejs` repo](https://github.com/hashicorp/demo-app-nodejs)
1. Use the [New Application](https://atlas.hashicorp.com/applications/new) tool to create your Node.js Application
1. **Choose a name for the application**: `aws-ap-northeast-1-nodejs`
1. **Compile Application**: checked
1. **Build Template**: `aws-ap-northeast-1-ubuntu-nodejs`
1. **Connect application to a GitHub repository**
1. **GitHub repository**: `demo-app-nodejs`
1. Leave both **Application directory** and **Application Template** blank

`demo-app-nodejs` にコミットするとコードをatlasにアップロードしてpackerのビルドを行う

```bash
$ git commit --allow-empty -m "Force a change in Atlas"
```

### Provision the `aws-global` Environment

Import Terraform Configuration from GitHub

* Name: aws-global
* Terraform dir: hashicorp-best-practices/terraform

`terraform push` で必要な変数がatlasに送られるらしいので

```bash
$ cd terraform/providers/aws/global
$ terraform remote config -backend-config name=$ATLAS_USERNAME/aws-global
$ terraform get
$ terraform push \
  -name $ATLAS_USERNAME/aws-global \
  -var "atlas_token=$ATLAS_TOKEN" \
  -var "atlas_username=$ATLAS_USERNAME"
```

この時点では `plan` が失敗するがそれはok

In Settings: check **Plan on artifact uploads** and click **Save**

In Variables: add the below Environment Variables with appropriate values

* `ATLAS_USERNAME`
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_DEFAULT_REGION`: `ap-northeast-1`
* `TF_ATLAS_DIR`: `providers/aws/global`

`domain` が `REPLACE_IN_ATLAS` のままなので Variables から編集する

In "Integrations": under "GitHub Integration" click **Update GitHub settings** to pull the latest configuration from master

In "Changes": click **Queue plan** if one has not already been queued, then **Confirm & Apply** to provision the `aws-global` environment

### Provision the `aws-ap-northeast-1-prod` Environment

Import Terraform Configuration from GitHub

* Name: aws-ap-northeast-1-prod
* Terraform dir: hashicorp-best-practices/terraform

`terraform push` で必要な変数がatlasに送られるらしいので

```bash
$ cd terraform/providers/aws/ap_northeast_1_prod
$ terraform remote config -backend-config name=$ATLAS_USERNAME/aws-ap-northeast-1-prod
$ terraform get
$ terraform push \
  -name $ATLAS_USERNAME/aws-ap-northeast-1-prod \
  -var "atlas_token=$ATLAS_TOKEN" \
  -var "atlas_username=$ATLAS_USERNAME"
```

この時点では `plan` が失敗するがそれはok

In Settings: check **Plan on artifact uploads** and click **Save**

In Variables: add the below Environment Variables with appropriate values

* `ATLAS_USERNAME`
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_DEFAULT_REGION`: `ap-northeast-1`
* `TF_ATLAS_DIR`: `providers/aws/ap_northeast_1_prod`

`REPLACE_IN_ATLAS` のままの変数を修正する

* Update `site_public_key` with the contents of `site.pub`
* Update `site_private_key` with the contents of `site.pem`
* Update `site_ssl_cert` with the contents of `site.crt`
* Update `site_ssl_key` with the contents of `site.key`
* Update `vault_ssl_cert` with the contents of `vault.crt`
* Update `vault_ssl_key` with the contents of `vault.key`

In "Integrations": under "GitHub Integration" click **Update GitHub settings** to pull the latest configuration from master

In "Changes": click **Queue plan** if one has not already been queued, then **Confirm & Apply** to provision the `aws-global` environment

### Provision the `aws-ap-northeast-1-staging` Environment

prodと同じなので割愛

### Setup Vault

```bash
# initialize vault
$ vault init | tee /tmp/vault.init > /dev/null
# retrive the unseal keys and root token from /tmp/vault.init and store these in a safe place
# shred keys and token once they are stored in a safe place
$ shred /tmp/vault.init
# use the unseal keys you just retrieved to unseal vault
$ vault unseal YOUR_UNSEAL_KEY_1
$ vault unseal YOUR_UNSEAL_KEY_2
$ vault unseal YOUR_UNSEAL_KEY_3
# authenticate with vault by entering your root token retrieved ealier
$ vault auth
# shred the token
$ shred -u -z ~/.vault-token
```

After Vault is initialized and unsealed, update the below variable(s) and apply the changes. Next time you deploy your application, you should see the Vault/Consul Template integration working in your Node.js website!

- [ ] In "Variables" of the `aws-ap-northeast-1-prod` environment: Update `vault_token` with the `root-token`
- [ ] Commit a new change (`git commit --allow-empty -m "Force a change in Atlas"`) to your [`demo-app-nodejs` repo](https://github.com/hashicorp/demo-app-nodejs), this should trigger a new "plan" in `aws-ap-northeast-1-prod` after a new artifact is built
- [ ] In "Changes" of the the `aws-ap-northeast-1-prod` environment: Queue a new plan and apply the changes to deploy the new application to see the Vault/Consul Template integration at work

You'll eventually want to [configure Vault](https://vaultproject.io/docs/index.html) specific to your needs and setup appropriate ACLs.

### Destroy

```bash
$ terraform destroy -var "atlas_token=$ATLAS_TOKEN" -var "atlas_username=$ATLAS_USERNAME"
```

## Code

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
