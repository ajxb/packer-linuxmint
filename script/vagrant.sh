#!/bin/bash -eux

echo '==> Configuring settings for vagrant'

VAGRANT_USER='vagrant'
VAGRANT_HOME="/home/${VAGRANT_USER}"

# Add vagrant user if it doesn't already exist
if ! id -u ${VAGRANT_USER} >/dev/null 2>&1; then
  echo "==> Creating ${VAGRANT_USER}"
  /usr/sbin/groupadd ${VAGRANT_USER}
  /usr/sbin/useradd ${VAGRANT_USER} -g ${VAGRANT_USER} -G wheel
  echo ${VAGRANT_USER}|passwd --stdin ${VAGRANT_USER}
fi

echo '==> Installing Vagrant SSH key'
# shellcheck disable=SC2174
mkdir -pm 700 "${VAGRANT_HOME}/.ssh"
# https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O "${VAGRANT_HOME}/.ssh/authorized_keys"
chmod 0600 "${VAGRANT_HOME}/.ssh/authorized_keys"
chown -R ${VAGRANT_USER}:${VAGRANT_USER} "${VAGRANT_HOME}/.ssh"

# Set up sudo
echo "==> Giving ${VAGRANT_USER} sudo powers"
echo "${VAGRANT_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

# keep proxy settings through sudo
echo 'Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY NO_PROXY PATH"' >> /etc/sudoers

# Fix stdin not being a tty
sed -i 's/^\(.*requiretty\)$/#\1/' /etc/sudoers
if grep -q -E "^mesg n$" /root/.profile && sed -i "s/^mesg n$/tty -s \\&\\& mesg n/g" /root/.profile; then
  echo '==> Fixed stdin not being a tty.'
fi
