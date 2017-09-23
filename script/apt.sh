#!/bin/bash -eux

echo "==> Configuring apt"
# Set apt to only resolve IPv4 addresses
echo "Acquire::ForceIPv4 \"true\";" >> /etc/apt/apt.conf.d/99force-ipv4
