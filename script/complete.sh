#!/bin/bash -eux

export DEBIAN_FRONTEND=noninteractive

source /etc/profile.d/golang.sh
source /etc/profile.d/swift.sh

echo
echo
echo
echo "---------------------------------------------"
echo "            BOX CREATION COMPLETED"
echo "---------------------------------------------"
echo
echo "The following development tools have been installed:"
echo
versions
echo
echo
