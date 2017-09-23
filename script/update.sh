#!/bin/bash -eux

apt="apt-get -qq -y"

echo "==> Updating list of repositories"
apt-get -y update

echo "==> Performing dist-upgrade (all packages and kernel)"
apt-get -y dist-upgrade
