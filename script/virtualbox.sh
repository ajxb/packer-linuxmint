#!/bin/bash -eux

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then

	apt="apt-get -qq -y"
	export DEBIAN_FRONTEND=noninteractive

	SSH_USER=${SSH_USERNAME:-vagrant}

	echo " =========================================== VIRTUALBOX ==========================================="
	echo " ==> apt command: $apt"

    echo "==> Installing linux-headers and dkms for VirtualBox guest additions"
    # Assuming the following packages are installed
    $apt install linux-headers-$(uname -r) build-essential perl
    $apt install dkms

    if [ -f /etc/init.d/virtualbox-ose-guest-utils ] ; then
        echo "==> The netboot installs the VirtualBox support (old) so we have to remove it."
        /etc/init.d/virtualbox-ose-guest-utils stop
        rmmod vboxguest
        $apt purge virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms virtualbox-ose-guest-utils
    elif [ -f /etc/init.d/virtualbox-guest-utils ] ; then
        echo "==> Stop and purge VirtualBox guest additions."
        /etc/init.d/virtualbox-guest-utils stop
        $apt purge virtualbox-guest-utils virtualbox-guest-dkms virtualbox-guest-x11
    fi

    VBOX_VERSION=$(cat /home/${SSH_USER}/.vbox_version)
    echo "==> VirtualBox version: $VBOX_VERSION"
    VBOX_ISO=/home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso
       
	cd /tmp
	if [ ! -f $VBOX_ISO ] ; then
	    echo "==> Need to download the ISO."
    	wget -q http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso -O $VBOX_ISO
	fi
	mount -o loop $VBOX_ISO /mnt
	sh /mnt/VBoxLinuxAdditions.run
	umount /mnt

	rm $VBOX_ISO

    $apt remove linux-headers-$(uname -r)
    $apt autoremove 
    
    VB_GRP="vboxsf"
    
    if grep -q "^${VB_GRP}:" /etc/group; then
        echo "==> Adding vagrant user to $VB_GRP group"
	    # Add vagrant user to vboxsf group
    	/usr/sbin/usermod -aG $VB_GRP $SSH_USER
    	
    	# Directories for host shared folder mount points
    	PRFX="/media/sf"
    	chng="chgrp $VB_GRP"
        mkdir ${PRFX}_tmp
        $chng ${PRFX}_tmp
        
        if "$DEVELOPER" = "dev"; then
	        mkdir ${PRFX}_repos
	        $chng ${PRFX}_repos
	        mkdir ${PRFX}_otherRepos
	        $chng ${PRFX}_otherRepos
		fi
        
    else
        echo "==> No $VB_GRP group found"
    fi
    
fi
