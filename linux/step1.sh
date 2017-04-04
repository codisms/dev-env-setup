#!/bin/bash

set -e
cd ~

. ~/.setup/linux/functions

setHostName() {
	echo SUDO=$SUDO
	echo Setting host name to "$1"...
	[ ! -f  /etc/sysconfig/network.orig ] && $SUDO cp -f /etc/sysconfig/network /etc/sysconfig/network.orig
	$SUDO sed "s|HOSTNAME=.\+\$|HOSTNAME=$1|" /etc/sysconfig/network.orig > /etc/sysconfig/network

	if [ -f /var/lib/dhclient/dhclient-eth0.leases ]; then
		[ ! -f /var/lib/dhclient/dhclient-eth0.leases.orig ] && $SUDO cp /var/lib/dhclient/dhclient-eth0.leases /var/lib/dhclient/dhclient-eth0.leases.orig
		$SUDO sed 's|option host-name "[a-f0-9-]\+"|option host-name "'$1'"|' /var/lib/dhclient/dhclient-eth0.leases.orig > /var/lib/dhclient/dhclient-eth0.leases
	fi

	$SUDO echo 127.0.0.1 $1>> /etc/hosts
}

#-----------------------------------------------------------------------------------------------------------
# Updates

updateSystem() {
	echo Configuration EPEL repository...
	$SUDO rpm -Uvh --quiet http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	$SUDO rpm -Uvh --quiet http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
	#$SUDO yum install -y https://centos6.iuscommunity.org/ius-release.rpm

	echo Updating system...
	$SUDO yum -y update
}

updateFileSystem() {
	if grep -q "^/dev/vdb1 /data" "/etc/mtab"; then
		[ ! -f /etc/fstab.orig ] && $SUDO cp /etc/fstab /etc/fstab.orig
		$SUDO cp -R /root/* /data/ || true
		$SUDO cp .* /data/ || true
		$SUDO cp -R /root/.ssh /data/ || true
		$SUDO cp -R /root/.setup /data/ || true
		$SUDO sed 's|/data|/root|' /etc/fstab.orig > /etc/fstab
	fi
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

scheduleForNextRun "$HOME/.setup/linux/step2.sh"

printHeader "Updating file system..."
updateFileSystem

printHeader "Finished step 1.  Rebooting..."
# read -p 'Press [Enter] to continue...'
reboot
