#!/bin/bash -eux

# Set apt to only resolve IPv4 addresses
echo '==> Configuring apt'
echo "Acquire::ForceIPv4 \"true\";" >> /etc/apt/apt.conf.d/99force-ipv4
