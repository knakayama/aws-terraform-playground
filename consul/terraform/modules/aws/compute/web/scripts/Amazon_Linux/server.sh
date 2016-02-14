#!/usr/bin/env bash

set -e

# Read from the file we created
SERVER_COUNT="$(cat "/tmp/consul-server-count" | tr -d '\n')"

# Write the flags to a temporary file
cat > "/tmp/consul_flags" <<EOT
export CONSUL_FLAGS="-server -bootstrap-expect=${SERVER_COUNT} -data-dir=/mnt/consul"
EOT

# Write it to the full service file
sudo mv "/tmp/consul_flags" "/etc/service/consul"
sudo chown root:root "/etc/service/consul"
sudo chmod 0644 "/etc/service/consul"

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=sh sw=2 ts=2 et
