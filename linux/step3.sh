#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

#-----------------------------------------------------------------------------------------------------------
# Installations

postInstall() {
	chmod 755 /root
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

	#yum install -y -q http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm
	#yum install -y -q postgresql94-odbc postgresql94-devel postgresql94 postgresql94-contrib postgresql94-server
	#/usr/pgsql-9.4/bin/postgresql94-setup initdb
	#systemctl start postgresql-9.4.service
	#systemctl enable postgresql-9.4.service

	yum install -y -q https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm
	yum install -y -q postgresql95-odbc postgresql95-devel postgresql95 postgresql95-contrib postgresql95-server
	/usr/pgsql-9.5/bin/postgresql95-setup initdb
	systemctl start postgresql-9.5.service
	systemctl enable postgresql-9.5.service

	ln -s ${MY_HOME}/.codisms/psqlrc ${MY_HOME}/.psqlrc
}

installVim() {
	printSubHeader "Installing vim..."

 	cd ${MY_HOME}
 	echo Cloning vim...
 	git clone https://github.com/vim/vim.git
 	cd vim
 	./configure --with-features=huge \
 				--enable-multibyte \
 				--enable-rubyinterp \
 				--enable-pythoninterp \
 				--enable-perlinterp \
 				--enable-luainterp \
 				--enable-gui=gtk2 --enable-cscope --prefix=/usr --quiet > /dev/null
# 				--with-python-config-dir=/usr/lib/python2.6/config \
 	make --quiet VIMRUNTIMEDIR=/usr/share/vim/vim74 > /dev/null
 	make install --quiet > /dev/null
 	cd ..
 	rm -rf vim

 	echo Removing existing version of vi/vim...
 	yum -y -q remove vim-common vim-enhanced vim-minimal

 	printSubHeader "Setting vim as default..."

 	update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
 	update-alternatives --set editor /usr/bin/vim
 	update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
 	update-alternatives --set vi /usr/bin/vim

	configureVim
	installVimExtensions_YCM

	cd ${MY_HOME}
}

configureVim() {
	printSubHeader "Configurating vim..."

	cd ${MY_HOME}
	git clone https://github.com/codisms/vim-config.git .vim
	cd .vim
	git submodule init
	git submodule update --init --recursive
	ln -s .vim/vimrc .vimrc
	ln -s .codisms/vimrc.dbext .vim/vimrc.dbext
}

installVimExtensions_YCM() {
	printSubHeader "Installing ycm..."

	cd ${MY_HOME}/.vim/bundle/YouCompleteMe
	#./install.py
	./install.py --clang-completer --system-libclang --gocode-completer > /dev/null
	cd ${MY_HOME}
}

installTmux() {
	echo Installing libevent 2.x...
	yum install -y libevent-2* libevent-devel-2*

	printSubHeader "Installing tmux..."

	cd ${MY_HOME}
	echo Cloning tmux...
	git clone https://github.com/tmux/tmux.git
	cd tmux
	sh autogen.sh --quiet > /dev/null
	#./configure --prefix=/usr/local #--quiet > /dev/null
	./configure --quiet > /dev/null
	make --quiet > /dev/null
	make install --quiet > /dev/null
	cd ..
	rm -rf tmux

#  	PATH=$PATH:`find /usr/local/rvm/rubies/ruby-*/bin/ | head -n 1`

# 	gem --update system
	gem install tmuxinator > /dev/null

	cd ${MY_HOME}
	git clone https://github.com/codisms/tmux-config.git .tmux
	cd .tmux
	git submodule init
	git submodule update --init --recursive
	cd ..
	ln -s .tmux/tmux.conf .tmux.conf
}

startServices() {
	printSubHeader "Starting services..."

	#startMySql

	echo Disabling firewalld...
	systemctl drop firewalld.service
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

scheduleForNextRun "${MY_HOME}/.setup/linux/step4.sh"

printHeader "Finished step 3.  Rebooting..."
# read -p 'Press [Enter] to continue...'

reboot

