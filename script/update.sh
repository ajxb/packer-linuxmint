#!/bin/bash -eux

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

echo '==> Updating list of repositories'
apt-get -y update

# Remove any pre-installed virtualbox packages
apt-get -y purge virtualbox*

echo '==> Performing dist-upgrade (all packages and kernel)'
apt-get -y dist-upgrade || {
    # hack for upgrade in 19 when upgrades of older versions fail
    # needs to be done after upgrade attempt, unsure why
    # https://forums.linuxmint.com/viewtopic.php?f=90&t=296589#p1649754
    echo '==> Fixing dpkg'
    dpkg --configure -a
    apt-get install -y -f

    apt-get -y dist-upgrade
}
