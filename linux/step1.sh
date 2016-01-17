#!/bin/bash

set -e
cd ~

. ~/.setup/linux/functions

setHostName() {
	echo Setting host name to "$1"...
	[ ! -f  /etc/sysconfig/network.orig ] && cp -f /etc/sysconfig/network /etc/sysconfig/network.orig
	sed "s|HOSTNAME=.\+\$|HOSTNAME=$1|" /etc/sysconfig/network.orig > /etc/sysconfig/network

	if [ -f /var/lib/dhclient/dhclient-eth0.leases ]; then
		[ ! -f /var/lib/dhclient/dhclient-eth0.leases.orig ] && cp /var/lib/dhclient/dhclient-eth0.leases /var/lib/dhclient/dhclient-eth0.leases.orig
		sed 's|option host-name "[a-f0-9-]\+"|option host-name "'$1'"|' /var/lib/dhclient/dhclient-eth0.leases.orig > /var/lib/dhclient/dhclient-eth0.leases
	fi

	echo 127.0.0.1 $1>> /etc/hosts
}

#-----------------------------------------------------------------------------------------------------------
# Updates

updateSystem() {
	echo Configuration EPEL repository...
	rpm -Uvh --quiet http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
	rpm -Uvh --quiet http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
	rpm -Uvh --quiet http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
	#rpm -Uvh --quiet http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
	#yum install -y https://centos6.iuscommunity.org/ius-release.rpm

	echo Updating system...
	yum -y update
}

updateFileSystem() {
	if grep -q "^/dev/vdb1 /data" "/etc/mtab"; then
		[ ! -f /etc/fstab.orig ] && cp /etc/fstab /etc/fstab.orig
		cp -R /root/* /data/ || true
		cp .* /data/ || true
		cp -R /root/.ssh /data/ || true
		cp -R /root/.setup /data/ || true
		sed 's|/data|/root|' /etc/fstab.orig > /etc/fstab
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
