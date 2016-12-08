#!/usr/bin/env bash

set -e
eval "$(jq -r '@sh "HOSTED_ZONE_ID=\(.hosted_zone_id)"')"

resource_record_sets="$(aws route53 list-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID")"

jq -n --arg "resource_record_sets" "$resource_record_sets" '{"Outputs": $resource_record_sets}'
