#!/usr/bin/env bash

set -x

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_NAME="aws.pem"
KEY_PATH="${CURRENT_DIR}/../terraform/providers/aws/ap_northeast_1_prod/keys/${KEY_NAME}"

if [[ ! -f "$KEY_PATH" ]]; then
  ssh-keygen -f "$KEY_PATH" -N ''
  chmod 400 "$KEY_PATH"
  chmod 600 "${KEY_PATH}.pub"
fi

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=sh sw=2 ts=2 et
