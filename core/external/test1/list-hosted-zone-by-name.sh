#!/usr/bin/env bash

set -e
eval "$(jq -r '@sh "DOMAIN=\(.domain)"')"

hosted_zone_id="$(aws route53 list-hosted-zones-by-name \
  --dns-name "$DOMAIN" \
  --query 'HostedZones[].Id' \
  --output text)"

jq -n --arg "hosted_zone_id" "$hosted_zone_id" '{"HostedZoneId": $hosted_zone_id}'
