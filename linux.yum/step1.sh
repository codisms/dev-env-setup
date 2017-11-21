#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

setHostName() {
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
	yum -y update
}

updateFileSystem() {
	if grep -q "^/dev/vdb1 /data" "/etc/mtab"; then
		[ ! -f /etc/fstab.orig ] &&  cp /etc/fstab /etc/fstab.orig
		cp -R /root/* /data/ || true
		cp .* /data/ || true
		cp -R /root/.ssh /data/ || true
		cp -R /root/.setup /data/ || true
		sed 's|/data|/root|' /etc/fstab.orig > /etc/fstab
	fi
}

updateSudoers() {
	echo Looking for user $MY_USER in /etc/sudoers...
	if ! grep -q $MY_USER /etc/sudoers; then
		echo " Adding user to /etc/sudoers..."
		echo "$MY_USER ALL=(ALL) NOPASSWD: ALL" | EDITOR='tee -a' visudo > /dev/null
	else
		echo "  User already exists"
		grep $MY_USER
	fi
	#cat /etc/sudoers
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

if [ -f /etc/sudoers ]; then
	printHeader "Updating /etc/sudoers..."
	updateSudoers
fi

resetPermissions

printHeader "Finished step 1.  Rebooting..."
# read -p 'Press [Enter] to continue...'
reboot
