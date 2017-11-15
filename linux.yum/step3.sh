#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

#-----------------------------------------------------------------------------------------------------------
# Installations

postInstall() {
	chmod 755 ${MY_HOME}
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

	yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
	yum install -y postgresql96-odbc postgresql96-devel postgresql96 postgresql96-contrib postgresql96-server
	/usr/pgsql-9.6/bin/postgresql96-setup initdb
	systemctl start postgresql-9.6.service
	systemctl enable postgresql-9.6.service

	ln -s ${MY_HOME}/.codisms/psqlrc ${MY_HOME}/.psqlrc
}

installVim() {
	printSubHeader "Installing vim..."

	${MY_HOME}/.codisms/bin/install-vim

#	cd ${MY_HOME}
#	echo Cloning vim...
#	retry git clone --depth=1 https://github.com/vim/vim.git
#
#	echo Building vim...
#	cd vim
#	./configure --with-features=huge \
#				--enable-multibyte \
#				--enable-rubyinterp \
#				--enable-pythoninterp \
#				--enable-perlinterp \
#				--enable-luainterp \
#				--enable-gui=gtk2 --enable-cscope --prefix=/usr --quiet > /dev/null
## 				--with-python-config-dir=/usr/lib/python2.6/config \
#	make --quiet > /dev/null
#
#	echo Removing existing version of vi/vim...
#	SUDO=$(which sudo 2> /dev/null)
#	#yum -y remove vim-common vim-enhanced vim-minimal
#	yum -y remove vim-common vim-enhanced
#	if [ "$SUDO" != "" ] && [ "$(which sudo 2> /dev/null)" == "" ]; then
#		echo Reinstalling sudo...
#		yum -y install sudo
#	fi
#
#	make install
#	cd ..
#	rm -rf vim
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
	echo Installing libevent 2.x...
	yum install -y libevent-2* libevent-devel-2*

	printSubHeader "Installing tmux..."

	${MY_HOME}/.codisms/bin/install-tmux 2.3
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

	echo Disabling firewalld...
	systemctl stop firewalld.service
	systemctl disable firewalld.service
}

startMySql() {
	systemctl start mysqld.service
	systemctl enable mysqld.service
}



############################################################################################################
# BEGIN
############################################################################################################

printHeader "Installing packages..."
installPackages

printHeader "Resetting home directory owner..."
resetPermissions

scheduleForNextRun "${MY_HOME}/.setup/linux.yum/step4.sh"

printHeader "Finished step 3.  Rebooting..."
# read -p 'Press [Enter] to continue...'

reboot

