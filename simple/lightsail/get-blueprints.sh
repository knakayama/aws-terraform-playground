#!/usr/bin/env bash

set -e
eval "$(jq -r '@sh "GROUP=\(.group)"')"

blueprint_id="$(aws lightsail get-blueprints \
  --region us-east-1 \
  --query 'blueprints[?group==`wordpress`].blueprintId' \
  --output text)"

jq -n --arg "blueprint_id" "$blueprint_id" '{"WpBlueprintId": $blueprint_id}'
