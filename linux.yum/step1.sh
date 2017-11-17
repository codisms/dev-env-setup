#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

setHostName() {
	echo SUDO=$SUDO
	echo Setting host name to "$1"...
	[ ! -f  /etc/sysconfig/network.orig ] && cp -f /etc/sysconfig/network /etc/sysconfig/network.orig
	sed -i "s|HOSTNAME=.\+\$|HOSTNAME=$1|" /etc/sysconfig/network

	if [ -f /var/lib/dhclient/dhclient-eth0.leases ]; then
		[ ! -f /var/lib/dhclient/dhclient-eth0.leases.orig ] && cp /var/lib/dhclient/dhclient-eth0.leases /var/lib/dhclient/dhclient-eth0.leases.orig
		sed -i 's|option host-name "[a-f0-9-]\+"|option host-name "'$1'"|' /var/lib/dhclient/dhclient-eth0.leases
	fi

	echo 127.0.0.1 $1>> /etc/hosts

	echo nameserver 8.8.8.8 >>/etc/resolv.conf
	echo nameserver 8.8.4.4 >>/etc/resolv.conf

	hostnamectl set-hostname $1
}

#-----------------------------------------------------------------------------------------------------------
# Updates

updateSystem() {
	echo Configuration deltarpm and extra repositories...
	yum install -y epel-release ius-release deltarpm

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

scheduleForNextRun "${MY_HOME}/.setup/linux.yum/step2.sh"

printHeader "Updating file system..."
updateFileSystem

resetPermissions

ls -la ${MY_HOME}
cat ${MY_HOME}/.onstart-setup

printHeader "Finished step 1.  Rebooting..."
# read -p 'Press [Enter] to continue...'
reboot
