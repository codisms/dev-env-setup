#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

#-----------------------------------------------------------------------------------------------------------
# Installations

postInstall() {
	$SUDO chmod 755 ${MY_HOME}
	[ -d ${MY_HOME}/web ] && chown -R apache:apache ${MY_HOME}/web

	startServices
}

installPackages() {
	installPostgres
	installVim
	installTmux

	postInstall
}

installPostgres() {
	printSubHeader "Installing postgresql..."

	#apt_get_install postgresql-9.5 postgresql-client-9.5 postgresql-common postgresql-contrib-9.5 postgresql-doc-9.5 postgresql-server-dev-9.5
	apt_get_install postgresql postgresql-contrib postgresql postgresql-client
	#/usr/pgsql-9.6/bin/postgresql96-setup initdb

	echo ""
	echo "To start PostgreSQL: systemctl start postgresql.service"
	echo "To have PostgreSQL start on boot: systemctl enable postgresql.service"
	echo ""

	ln -s ${MY_HOME}/.codisms/psqlrc ${MY_HOME}/.psqlrc
}

installVim() {
	printSubHeader "Installing vim..."

	$SUDO ${MY_HOME}/.codisms/bin/install-vim --pwd=${MY_HOME} --build

#	apt_add_repository ppa:jonathonf/vim
#	apt_get_install vim
#
#	printSubHeader "Setting vim as default..."
#	update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
#	update-alternatives --set editor /usr/bin/vim
#	update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
#	update-alternatives --set vi /usr/bin/vim
#
#	configureVim
#	installVimExtensions_YCM
#
#	cd ${MY_HOME}
}

#configureVim() {
#	printSubHeader "Downloading vim configuration..."
#	cd ${MY_HOME}
#	retry git clone https://github.com/codisms/vim-config.git .vim
#
#	echo "Downloading submodules..."
#	cd ${MY_HOME}/.vim
#	retry git submodule update --init --recursive
#
#	printSubHeader "Configuring vim..."
#	ln -s ${MY_HOME}/.vim/vimrc ${MY_HOME}/.vimrc
#	ln -s ${MY_HOME}/.codisms/vimrc.dbext ${MY_HOME}/.vim/vimrc.dbext
#}
#
#installVimExtensions_YCM() {
#	printSubHeader "Installing ycm..."
#
#	cd ${MY_HOME}/.vim/bundle/YouCompleteMe
#	#./install.py
#	retry ./install.py --clang-completer --gocode-completer --tern-completer
#	#./install.py --clang-completer --system-libclang --gocode-completer > /dev/null
#	cd ${MY_HOME}
#}

installTmux() {
	printSubHeader "Installing libevent 2.x..."
	apt_get_install libevent-2* libevent-dev

	printSubHeader "Installing tmux..."

	$SUDO ${MY_HOME}/.codisms/bin/install-tmux --version=2.6 --pwd=${MY_HOME} --build
	#cd ${MY_HOME}
	#echo Cloning tmux...
	#retry git clone --depth=1 -b 2.3 https://github.com/tmux/tmux.git

	#echo Compiling tmux...
	#cd tmux
	#sh autogen.sh --quiet > /dev/null
	##./configure --prefix=/usr/local #--quiet > /dev/null
	#./configure --quiet > /dev/null
	#make --quiet > /dev/null

	#echo Installing tmux...
	#make install --quiet > /dev/null
	#cd ..
	#rm -rf tmux

	##gem --update system
	#gem install tmuxinator > /dev/null

	#printSubHeader "Downloading tmux configuration..."
	#cd ${MY_HOME}
	#retry git clone https://github.com/codisms/tmux-config.git .tmux

	#echo "Downloading submodules..."
	#cd .tmux
	#retry git submodule update --init --recursive
	#cd ..

	#printSubHeader "Configuring tmux..."
	#ln -s .tmux/tmux.conf .tmux.conf
}

startServices() {
	printSubHeader "Starting services..."

	#startMySql

	if hash ufw 2>/dev/null; then
		echo Disabling firewalld...
		$SUDO ufw disable
	fi
}

startMySql() {
	$SUDO systemctl start mysqld.service
	$SUDO systemctl enable mysqld.service
}



############################################################################################################
# BEGIN
############################################################################################################

printHeader "Installing packages..."
installPackages

printHeader "Resetting home directory owner..."
resetPermissions

scheduleForNextRun "${MY_HOME}/.setup/linux.apt/step4.sh"

printHeader "Finished step 3.  Rebooting..."
# read -p 'Press [Enter] to continue...'

$SUDO reboot

