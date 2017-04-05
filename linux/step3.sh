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
 	git clone --quiet https://github.com/vim/vim.git
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

	#ln -s ${MY_HOME}/.codisms/vim/vimrc ${MY_HOME}/.vimrc
	#ln -s ${MY_HOME}/.codisms/vim/vimrc.dbext ${MY_HOME}/.vimrc.dbext
	#ln -s ${MY_HOME}/.codisms/vim ${MY_HOME}/.vim
	cd ${MY_HOME}
	git clone https://github.com/codisms/vim-config.git .vim
	cd .vim
	git submodule init
	git submodule update --init --recursive
	cd bundle/YouCompleteMe
	./install.py
	cd ${MY_HOME}
	ln -s .vim/vimrc .vimrc
	ln -s .codisms/vim/vimrc.dbext .vim/vimrc.dbext

 	echo Removing existing version of vi/vim...
 	yum -y -q remove vim-common vim-enhanced vim-minimal

 	printSubHeader "Setting vim as default..."

 	update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
 	update-alternatives --set editor /usr/bin/vim
 	update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
 	update-alternatives --set vi /usr/bin/vim

	installVimExtensions
}

installVimExtensions() {
	printSubHeader "Installing vim extensions..."

	mkdir -p ${MY_HOME}/.vim/autoload
	mkdir -p ${MY_HOME}/.vim/bitmaps
	mkdir -p ${MY_HOME}/.vim/bundle
	mkdir -p ${MY_HOME}/.vim/colors
	mkdir -p ${MY_HOME}/.vim/doc

	ln -s ${MY_HOME}/.codisms/repos/vim-pathogen/autoload/pathogen.vim ${MY_HOME}/.vim/autoload/pathogen.vim
	ln -s ${MY_HOME}/.codisms/repos/solarized/vim-colors-solarized/autoload/togglebg.vim ${MY_HOME}/.vim/autoload/togglebg.vim

	ln -s ${MY_HOME}/.codisms/repos/solarized/vim-colors-solarized/bitmaps/togglebg.png ${MY_HOME}/.vim/bitmaps/togglebg.png

	ln -s ${MY_HOME}/.codisms/repos/vim-colors-solarized ${MY_HOME}/.vim/bundle/vim-colors-solarized
	#ln -s ${MY_HOME}/.codisms/repos/tslime.vim ${MY_HOME}/.vim/bundle/tslime.vim
	ln -s ${MY_HOME}/.codisms/repos/pgsql.vim ${MY_HOME}/.vim/bundle/pgsql.vim
	ln -s ${MY_HOME}/.codisms/repos/dbext.vim ${MY_HOME}/.vim/bundle/dbext.vim
	#ln -s ${MY_HOME}/.vim/repos/vim-neatstatus ${MY_HOME}/.vim/bundle/vim-neatstatus
	ln -s ${MY_HOME}/.codisms/repos/taboo.vim ${MY_HOME}/.vim/bundle/taboo.vim
	ln -s ${MY_HOME}/.codisms/repos/vim-go ${MY_HOME}/.vim/bundle/vim-go
	ln -s ${MY_HOME}/.codisms/repos/vim-ruby ${MY_HOME}/.vim/bundle/vim-ruby
	ln -s ${MY_HOME}/.codisms/repos/vim-obsession ${MY_HOME}/.vim/bundle/vim-obsession
	ln -s ${MY_HOME}/.codisms/repos/vim-javascript ${MY_HOME}/.vim/bundle/vim-javascript
	ln -s ${MY_HOME}/.codisms/repos/typescript-vim ${MY_HOME}/.vim/bundle/typescript-vim
	ln -s ${MY_HOME}/.codisms/repos/syntastic ${MY_HOME}/.vim/bundle/syntastic

	ln -s ${MY_HOME}/.codisms/repos/solarized/vim-colors-solarized/colors/solarized.vim ${MY_HOME}/.vim/colors/solarized.vim

	ln -s ${MY_HOME}/.codisms/repos/dbext.vim/doc/dbext.txt ${MY_HOME}/.vim/doc/dbext.txt

	installVimExtensions_YCM
}

installVimExtensions_YCM() {
	printSubHeader "Installing ycm..."

	cd ${MY_HOME}/.codisms/repos/YouCompleteMe
	./install.py --clang-completer --system-libclang --gocode-completer > /dev/null
	cd ${MY_HOME}

	ln -s ${MY_HOME}/.codisms/repos/YouCompleteMe ${MY_HOME}/.vim/bundle/YouCompleteMe
}

# installLibEvent() {
# 	printSubHeader "Installing libevent..."
#
# 	cd ${MY_HOME}
# 	echo Cloning libevent...
# 	git clone --quiet https://github.com/libevent/libevent.git
# 	cd libevent
# 	sh autogen.sh --quiet > /dev/null
# 	./configure --prefix=/usr/local --quiet > /dev/null
# 	make --quiet > /dev/null
# 	make install --quiet > /dev/null
# 	cd ..
# 	rm -rf libevent
#
# 	yum install -y -q libevent libevent-devel
# }

installTmux() {
# 	installLibEvent

	echo Installing libevent 2.x...
	yum install -y libevent-2* libevent-devel-2*

	printSubHeader "Installing tmux..."

	cd ${MY_HOME}
	echo Cloning tmux...
	git clone --quiet https://github.com/tmux/tmux.git
	#git clone https://github.com/tmux/tmux.git
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
	#gem install --quiet tmuxinator > /dev/null

	#ln -s .codisms/tmuxinator .tmuxinator
	#ln -s ${MY_HOME}/.codisms/tmux/tmux.conf ${MY_HOME}/.tmux.conf
	#ln -s ${MY_HOME}/.codisms/tmux ${MY_HOME}/.tmux

	#[ -d ${MY_HOME}/.codisms/tmux/plugins ] && rm -f ${MY_HOME}/.codisms/tmux/plugins
	#mkdir ${MY_HOME}/.codisms/tmux/plugins
	#ln -s ${MY_HOME}/.codisms/repos/tpm ${MY_HOME}/.codisms/tmux/plugins/tpm
	#ln -s ${MY_HOME}/.codisms/repos/tmux-resurrect ${MY_HOME}/.codisms/tmux/plugins/tmux-resurrect
	#ln -s ${MY_HOME}/.codisms/repos/tmux-continuum ${MY_HOME}/.codisms/tmux/plugins/tmux-continuum
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

	#echo Setting up vpn-veritone...
	#cp -f ${MY_HOME}/.codisms/bin/vpn-veritone.service /etc/systemd/system/vpn-veritone.service
	#echo Starting vpn-veritone...
	#systemctl start vpn-veritone.service
	#echo Setting vpn-veritone for auto start...
	#systemctl enable vpn-veritone.service

	#echo Setting up vpn-payoff...
	#cp -f ${MY_HOME}/.codisms/bin/vpn-payoff.service /etc/systemd/system/vpn-payoff.service

	echo Disabling firewalld...
	systemctl drop firewalld.service
	systemctl disable firewalld.service
}

#startMySql() {
#	systemctl start mysqld.service
#	systemctl enable mysqld.service
#}



############################################################################################################
# BEGIN
############################################################################################################

printHeader "Installing packages..."
installPackages

scheduleForNextRun "${MY_HOME}/.setup/linux/step4.sh"

printHeader "Finished step 3.  Rebooting..."
# read -p 'Press [Enter] to continue...'

reboot

