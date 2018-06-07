#!/bin/bash -eux

# Get release information
# shellcheck disable=SC1091
. /etc/os-release

# Configure the Puppet apt repository (UBUNTU_CODENAME is defined in os-release)
PUPPET_RELEASE="puppet5-release-${UBUNTU_CODENAME}.deb"
PUPPET_URL='http://apt.puppetlabs.com'

if [[ "${UBUNTU_CODENAME}" == 'bionic' ]]; then
  echo '==> BIONIC'
  PUPPET_RELEASE="puppet5-nightly-release-bionic.deb"
  PUPPET_URL='http://nightlies.puppet.com/apt'
fi

echo "==> Downloading ${PUPPET_RELEASE}"
COUNTER=10
until [[ ${COUNTER} -eq 0 ]]; do

  if wget "${PUPPET_URL}/${PUPPET_RELEASE}"; then
    break
  fi

  (( COUNTER-- ))
done

echo "==> Installing ${PUPPET_RELEASE}"
dpkg -i "${PUPPET_RELEASE}"

echo '==> Updating apt database'
apt-get update

# Install Puppet
echo '==> Installing Puppet'
apt-get -y -q install puppet-agent

echo '==> Installing ruby'
apt-get -y -q install ruby

echo '==> Installing librarian-puppet'
gem install librarian-puppet

# Clean up
echo '==> Cleaning up'
rm -f "${PUPPET_RELEASE}"
