#!/bin/bash

set -e
cd ~

. ~/.setup/linux/functions

setHostName() {
	echo Setting host name to "$1"...
	[ -f  /etc/sysconfig/network ] && mv -f /etc/sysconfig/network /etc/sysconfig/network.orig

	cat << EOF > /etc/sysconfig/network
echo NETWORKING=yes
echo HOSTNAME=$1
EOF

	echo 127.0.0.1 $1>> /etc/hosts
}

#-----------------------------------------------------------------------------------------------------------
# Installations

updateSystem() {
	echo Configuration EPEL repository...
	rpm -ivh --quiet http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
	#yum install -y https://centos6.iuscommunity.org/ius-release.rpm

	echo Updating system...
	yum -y update
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

printHeader "Finished step 1.  Rebooting..."
# read -p 'Press [Enter] to continue...'
reboot
