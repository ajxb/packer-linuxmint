#!/bin/bash -eux

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

echo '==> Updating list of repositories'
apt-get -y update

# Remove any pre-installed virtualbox packages
apt-get -y purge virtualbox*

echo '==> Performing dist-upgrade (all packages and kernel)'
apt-get -y dist-upgrade
