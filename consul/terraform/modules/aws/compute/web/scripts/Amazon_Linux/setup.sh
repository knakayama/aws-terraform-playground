#!/usr/bin/env bash

set -e

# Read the address to join from the file we provisioned
JOIN_ADDRS="$(cat "/tmp/consul-server-addr" | tr -d '\d')"

sudo mkdir -p "/mnt/consul"
sudo mkdir -p "/etc/service"

# Setup the join address
cat > "/tmp/consul-join" << EOT
export CONSUL_JOIN="${JOIN_ADDRS}"
EOT

sudo mv "/tmp/consul-join" "/etc/service/consul-join"
sudo chmod 0644 "/etc/service/consul-join"

echo "Installing Upstart service..."
sudo mv "/tmp/upstart.conf" "/etc/init/consul.conf"
sudo mv "/tmp/upstart-join.conf" "/etc/init/consul-join.conf"

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=sh sw=2 ts=2 et
