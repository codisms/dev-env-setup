#!/bin/bash

set -e
cd ~

. ./functions

setHostName() {
	echo Setting host name to "$1"...
	[ -f  /etc/sysconfig/network ] && mv -f /etc/sysconfig/network /etc/sysconfig/network.orig

	cat << EOF > /etc/sysconfig/network
echo NETWORKING=yes
echo HOSTNAME=$1
EOF

	echo 127.0.0.1 $1>> /etc/hosts
}

############################################################################################################
# BEGIN
############################################################################################################

if [ "$1" != "" ]; then
	printHeader "Setting host name..."
	setHostName $1

# 	echo
# 	echo Rebooting machine for changes to take effect...
# 	read -p 'Press [Enter] to continue...'
# 	reboot
# 	exit
fi

~/.setup/linux/setup_step1.sh
