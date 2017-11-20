#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

setHostName() {
	echo SUDO=$SUDO
	echo Setting host name to "$1"...

	echo nameserver 8.8.8.8 >>/etc/resolv.conf
	echo nameserver 8.8.4.4 >>/etc/resolv.conf

	echo 127.0.0.1 $1>> /etc/hosts

	hostnamectl set-hostname $1
}

#-----------------------------------------------------------------------------------------------------------
# Updates

updateSystem() {
	echo Updating system...
	apt_get_update
}

#updateFileSystem() {
#	if grep -q "^/dev/vdb1 /data" "/etc/mtab"; then
#		[ ! -f /etc/fstab.orig ] && $SUDO cp /etc/fstab /etc/fstab.orig
#		$SUDO cp -R /root/* /data/ || true
#		$SUDO cp .* /data/ || true
#		$SUDO cp -R /root/.ssh /data/ || true
#		$SUDO cp -R /root/.setup /data/ || true
#		$SUDO sed 's|/data|/root|' /etc/fstab.orig > /etc/fstab
#	fi
#}

updateSudoers() {
	echo Looking for user $(whoami) in /etc/sudoers...
	if $SUDO grep -q $(whoami) /etc/sudoers; then
		echo Adding user to /etc/sudoers...
		echo "$(whoami) ALL=(ALL:ALL) ALL" | $SUDO EDITOR='tee -a' visudo > /dev/null
	else
		echo "  User already exists"
	fi
	$SUDO cat /etc/sudoers
}

############################################################################################################
# BEGIN
############################################################################################################

if [ "$1" != "" ]; then
	printHeader "Setting host name..."
	setHostName $1
fi

printHeader "Updating system..."
updateSystem

if [ -f /etc/sudoers ]; then
	printHeader "Updating /etc/sudoers..."
	updateSudoers
fi

scheduleForNextRun "${MY_HOME}/.setup/linux.apt/step2.sh"

# This is a Joyent thing; not sure if it's needed
#printHeader "Updating file system..."
#updateFileSystem

printHeader "Finished step 1.  Rebooting..."
# read -p 'Press [Enter] to continue...'
reboot
