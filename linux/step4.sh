#!/bin/bash

set -e
cd ~

. ~/.setup/linux/functions

#-----------------------------------------------------------------------------------------------------------
# Download code

downloadCode() {
	echo Cloning db... && git clone --quiet https://bitbucket.org/codisms/db.git ~/db
	~/.codisms/get-code.sh
}

finalConfigurations() {
	[ -f /etc/motd ] && mv /etc/motd /etc/motd.orig
	ln -s ~/.codisms/motd /etc/motd

	[ -f /etc/ptmp ] && rm -f /etc/ptmp
	chsh -s `which zsh`
}

############################################################################################################
# BEGIN
############################################################################################################

printHeader "Downloading code..."
downloadCode

printHeader "Making final configuration changes..."
finalConfigurations

printHeader "Done.  Rebooting for the final time..."
# read -p 'Press [Enter] to continue...'

reboot
