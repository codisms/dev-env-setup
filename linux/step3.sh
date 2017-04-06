#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

echo SUDO1=`which sudo`

#-----------------------------------------------------------------------------------------------------------
# Installations

postInstall() {
echo SUDO2=`which sudo`
	chmod 755 ${MY_HOME}
	[ -d ${MY_HOME}/web ] && chown -R apache:apache ${MY_HOME}/web

echo SUDO3=`which sudo`
	startServices
echo SUDO4=`which sudo`
}

installPackages() {
echo SUDO5=`which sudo`
	installPostgres
echo SUDO6=`which sudo`
	installVim
echo SUDO7=`which sudo`
	installTmux
echo SUDO8=`which sudo`

	postInstall
echo SUDO9=`which sudo`
}

installPostgres() {
	printSubHeader "Installing postgresql..."

echo SUDO10=`which sudo`
	yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
echo SUDO11=`which sudo`
	yum install -y postgresql96-odbc postgresql96-devel postgresql96 postgresql96-contrib postgresql96-server
echo SUDO12=`which sudo`
	/usr/pgsql-9.6/bin/postgresql96-setup initdb
	systemctl start postgresql-9.6.service
	systemctl enable postgresql-9.6.service
echo SUDO13=`which sudo`

	ln -s ${MY_HOME}/.codisms/psqlrc ${MY_HOME}/.psqlrc
}

installVim() {
echo SUDO14=`which sudo`
	printSubHeader "Installing vim..."

 	cd ${MY_HOME}
 	echo Cloning vim...
 	git clone --depth=1 https://github.com/vim/vim.git

	echo Building vim...
 	cd vim
 	./configure --with-features=huge \
 				--enable-multibyte \
 				--enable-rubyinterp \
 				--enable-pythoninterp \
 				--enable-perlinterp \
 				--enable-luainterp \
 				--enable-gui=gtk2 --enable-cscope --prefix=/usr --quiet > /dev/null
# 				--with-python-config-dir=/usr/lib/python2.6/config \
echo SUDO14a=`which sudo`
 	make --quiet VIMRUNTIMEDIR=/usr/share/vim/vim74 > /dev/null
echo SUDO14b=`which sudo`
 	make install --quiet > /dev/null
echo SUDO14c=`which sudo`
 	cd ..
 	rm -rf vim

echo SUDO14d=`which sudo`
 	echo Removing existing version of vi/vim...
 	yum -y remove vim-common vim-enhanced vim-minimal
	if [ "$SUDO" != "" ] && [ "$(which sudo 2> /dev/null)" == "" ]; then
		echo Reinstalling sudo...
		yum -y install sudo
	fi

echo SUDO15=`which sudo`
 	printSubHeader "Setting vim as default..."
 	update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
 	update-alternatives --set editor /usr/bin/vim
 	update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
 	update-alternatives --set vi /usr/bin/vim

echo SUDO16=`which sudo`
	configureVim
echo SUDO17=`which sudo`
	installVimExtensions_YCM
echo SUDO18=`which sudo`

	cd ${MY_HOME}
}

configureVim() {
	printSubHeader "Downloading vim configuration..."
	cd ${MY_HOME}
	git clone https://github.com/codisms/vim-config.git .vim

	echo "Downloading submodules..."
	cd ${MY_HOME}/.vim
	#git submodule init
	git submodule update --init --recursive

	printSubHeader "Configuring vim..."
	ln -s ${MY_HOME}/.vim/vimrc ${MY_HOME}/.vimrc
	ln -s ${MY_HOME}/.codisms/vimrc.dbext ${MY_HOME}/.vim/vimrc.dbext
}

installVimExtensions_YCM() {
	printSubHeader "Installing ycm..."

	cd ${MY_HOME}/.vim/bundle/YouCompleteMe
	#./install.py
	./install.py --clang-completer --gocode-completer --tern-completer > /dev/null
	#./install.py --clang-completer --system-libclang --gocode-completer > /dev/null
	cd ${MY_HOME}
}

installTmux() {
echo SUDO19=`which sudo`
	echo Installing libevent 2.x...
	yum install -y libevent-2* libevent-devel-2*
echo SUDO20=`which sudo`

	printSubHeader "Installing tmux..."

	cd ${MY_HOME}
	echo Cloning tmux...
	git clone --depth=1 https://github.com/tmux/tmux.git
echo SUDO21=`which sudo`

	echo Compiling tmux...
	cd tmux
	sh autogen.sh --quiet > /dev/null
	#./configure --prefix=/usr/local #--quiet > /dev/null
	./configure --quiet > /dev/null
	make --quiet > /dev/null
echo SUDO21=`which sudo`

	echo Installing tmux...
	make install --quiet > /dev/null
	cd ..
	rm -rf tmux
echo SUDO22=`which sudo`

 	#gem --update system
	gem install tmuxinator > /dev/null
echo SUDO23=`which sudo`

	printSubHeader "Downloading tmux configuration..."
	cd ${MY_HOME}
	git clone https://github.com/codisms/tmux-config.git .tmux
echo SUDO24=`which sudo`

	echo "Downloading submodules..."
	cd .tmux
	#git submodule init
	git submodule update --init --recursive
	cd ..
echo SUDO25=`which sudo`

	printSubHeader "Configuring tmux..."
	ln -s .tmux/tmux.conf .tmux.conf
}

startServices() {
	printSubHeader "Starting services..."

echo SUDO26=`which sudo`
	#startMySql

	echo Disabling firewalld...
	systemctl stop firewalld.service
	systemctl disable firewalld.service
echo SUDO27=`which sudo`
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

scheduleForNextRun "${MY_HOME}/.setup/linux/step4.sh"

printHeader "Finished step 3.  Rebooting..."
# read -p 'Press [Enter] to continue...'

echo SUDO28=`which sudo`
reboot

