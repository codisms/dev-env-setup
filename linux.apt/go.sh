#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

if [ "$1" != "" ]; then
	source ./set-host-name.sh $1
fi

source ./fix-local.sh
source ./check-for-swap.sh
source ./install-ap-fast.sh
source ./update-system.sh

if [ -f /etc/sudoers ]; then
	source ./update-sudoers.sh
fi

# This is a Joyent thing; not sure if it's needed
#printHeader "Updating file system..."
#source ./update-file-system.sh

reloadEnvironment
resetPermissions
cleanBoot

source ./download-repos.sh

#-----------------------------------------------------------------------------------------------------------
# Create a SSH key, if needed
if [ ! -f ${MY_HOME}/.ssh/id_rsa ]; then
	source ./generate-ssh-key.sh
fi

source ./configure-environment.sh
source ./install-packages.sh
source ./install-languages

reloadEnvironment
resetPermissions
cleanBoot

source ./install-fonts.sh
source ./install-tools.sh
source ./install-packages.sh
source ./final-configurations.sh
source ./final-cleanup.sh

#read -p "Download pre-defined code projects? (y/n) " -n 1 -r
#echo
#if [[ $REPLY =~ ^[Yy]$ ]]; then
#	printHeader "Downloading code..." "dl-code"
#	cd ~
#	~/.codisms/get-code.sh
#	#rsync -avzhe ssh --progress dev.codisms.com:/root/ /root/
#fi

cd ${MY_HOME}/.codisms
git checkout -- zshrc

reloadEnvironment
resetPermissions
cleanBoot

printHeader "Done.  \e[5mRebooting\e[25m for the final time..." "reboot"
echo -ne '\007'

$SUDO reboot

