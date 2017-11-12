#!/bin/bash -eux

if [[ "${PACKER_BUILDER_TYPE}" =~ 'virtualbox' ]]; then
    echo '==> Installing VirtualBox guest additions'
    # Assume that we've installed all the prerequisites:
    # kernel-headers-$(uname -r) kernel-devel-$(uname -r) gcc make perl
    # from the install media

    VBOX_VERSION=$(cat ~/.vbox_version)
    mount -o loop ~/"VBoxGuestAdditions_${VBOX_VERSION}.iso" /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm -rf ~/"VBoxGuestAdditions_${VBOX_VERSION}.iso"
    rm -f ~/.vbox_version
fi
