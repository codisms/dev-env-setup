#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

checkForSwap() {
	printHeader "Checking memory requirements", "mem"

	# https://unix.stackexchange.com/a/233287
	#FREE_MEMORY=$(free | awk -v RS="" '{ print $10 / 1024; }' | bc)
	MAIN_MEMORY=$(cat /proc/meminfo | grep -e 'MemFree' | awk -v RS="" '{ print $2; }')
	SWAP_MEMORY=$(cat /proc/meminfo | grep -e 'SwapFree' | awk -v RS="" '{ print $2; }')
	FREE_MEMORY=$(($SWAP_MEMORY + $MAIN_MEMORY))

	SWAP_NEEDED=0
	echo MAIN_MEMORY = ${MAIN_MEMORY}
	echo SWAP_MEMORY = ${SWAP_MEMORY}
	echo FREE_MEMORY = ${FREE_MEMORY}
	if [ $FREE_MEMORY -lt 4194304 ]; then
		echo -e "\e[31;5mLow memory detected; expanding swap...\e[0m"
		SWAP_NEEDED=1
	else
		if [ $SWAP_MEMORY -eq 0 ]; then
			echo -e "\e[31;5mNo swap detected; creating swap file...\e[0m"
			SWAP_NEEDED=1
		fi
	fi

	if [ $SWAP_NEEDED -eq 1 ]; then
		# https://serverfault.com/questions/218750/why-dont-ec2-ubuntu-images-have-swap/279632#279632
		# https://www.computerhope.com/unix/swapon.htm
		$SUDO dd if=/dev/zero of=/var/swapfile bs=1M count=4196
		$SUDO chmod 600 /var/swapfile
		$SUDO mkswap /var/swapfile
		$SUDO cp /etc/fstab /etc/fstab.bak
		echo /var/swapfile none swap defaults 0 0 | $SUDO tee -a /etc/fstab > /dev/null
		$SUDO swapon -a
	fi
}

setHostName() {
	printHeader "Setting host name..." "hostname"

	echo SUDO=$SUDO
	echo Setting host name to "$1"...

	$SUDO sh -c "echo nameserver 8.8.8.8 >>/etc/resolv.conf; \
		echo nameserver 8.8.4.4 >>/etc/resolv.conf; \
		echo 127.0.0.1 $1>> /etc/hosts"

	$SUDO hostnamectl set-hostname $1
}

#-----------------------------------------------------------------------------------------------------------
# Updates

installAptFast() {
	printHeader "Installing apt-fast..." "apt-fast"

	apt_add_repository ppa:apt-fast/stable
	apt_get_update
	apt_get_install apt-fast
	#mkdir -p ${MY_HOME}/.config/aria2/
	#echo "log-level=warn" >> ~/.config/aria2/input.conf

	reloadEnvironment
}

updateSystem() {
	printHeader "Updating system..." "system"

	export LC_ALL="en_US.UTF-8"
	export LC_CTYPE="en_US.UTF-8"
	retry_long $SUDO dpkg-reconfigure locales

	apt_get_update

	reloadEnvironment
}

#updateFileSystem() {
#	if grep -q "^/dev/vdb1 /data" "/etc/mtab"; then
#		[ ! -f /etc/fstab.orig ] && cp /etc/fstab /etc/fstab.orig
#		cp -R /root/* /data/ || true
#		cp .* /data/ || true
#		cp -R /root/.ssh /data/ || true
#		cp -R /root/.setup /data/ || true
#		sed 's|/data|/root|' /etc/fstab.orig > /etc/fstab
#	fi
#}

updateSudoers() {
	printHeader "Updating /etc/sudoers..." "sudoers"

	echo Looking for user $MY_USER in /etc/sudoers...
	if ! $SUDO grep -q $MY_USER /etc/sudoers; then
		echo "  Adding user to /etc/sudoers..."
		echo "$MY_USER ALL=(ALL:ALL) NOPASSWD: ALL" | $SUDO EDITOR='tee -a' visudo > /dev/null
	else
		echo "  User already exists"
		grep $MY_USER /etc/sudoers
	fi
	#cat /etc/sudoers
}

############################################################################################################
# BEGIN
############################################################################################################

if [ "$1" != "" ]; then
	setHostName $1
fi

checkForSwap
installAptFast
updateSystem

if [ -f /etc/sudoers ]; then
	updateSudoers
fi

#scheduleForNextRun "${MY_HOME}/.setup/linux.apt/step2.sh"
#
## This is a Joyent thing; not sure if it's needed
##printHeader "Updating file system..."
##updateFileSystem
#
#printHeader "Finished step 1.  \e[5mRebooting\e[25m..." "reboot"
#echo -ne '\007'
## read -p 'Press [Enter] to continue...'
#
#$SUDO reboot

source "${MY_HOME}/.setup/linux.apt/step2.sh"

