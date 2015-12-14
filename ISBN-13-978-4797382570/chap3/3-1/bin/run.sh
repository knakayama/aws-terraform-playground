#!/usr/bin/env bash

set -x

cd provisioner
export EC2_INI_PATH="./ec2.ini"
ansible-playbook \
  --inventory-file ./ansible/contrib/inventory/ec2.py \
  site.yml \
  --limit tag_Name_WP_WebAPP \
  --extra-vars "@config.yml" \
  -vv \
  $@

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=sh sw=2 ts=2 et
