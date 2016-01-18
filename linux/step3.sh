#!/bin/bash

set -e
cd ~

. ~/.setup/linux/functions

#-----------------------------------------------------------------------------------------------------------
# Installations

postInstall() {
	chmod 755 /root
	[ -d ~/web ] && chown -R apache:apache ~/web

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

	yum install -y -q http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm
	yum install -y -q postgresql94-odbc postgresql94-devel postgresql94 postgresql94-contrib postgresql94-server
	/usr/pgsql-9.4/bin/postgresql94-setup initdb
	systemctl start postgresql-9.4.service
	systemctl enable postgresql-9.4.service

	ln -s ~/.codisms/psqlrc ~/.psqlrc
}

installVim() {
	printSubHeader "Installing vim..."

# 	cd ~
# 	echo Cloning vim...
# 	git clone --quiet https://github.com/vim/vim.git
# 	cd vim
# 	./configure --with-features=huge \
# 				--enable-multibyte \
# 				--enable-rubyinterp \
# 				--enable-pythoninterp \
# 				--with-python-config-dir=/usr/lib/python2.6/config \
# 				--enable-perlinterp \
# 				--enable-luainterp \
# 				--enable-gui=gtk2 --enable-cscope --prefix=/usr --quiet > /dev/null
# 	make --quiet VIMRUNTIMEDIR=/usr/share/vim/vim74 > /dev/null
# 	make install --quiet > /dev/null
# 	cd ..
# 	rm -rf vim

	ln -s ~/.codisms/vim/vimrc ~/.vimrc
	ln -s ~/.codisms/vim ~/.vim

# 	echo Removing existing version of vi/vim...
# 	yum -y -q remove vim-common vim-enhanced vim-minimal
#
# 	printSubHeader "Setting vim as default..."
#
# 	update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
# 	update-alternatives --set editor /usr/bin/vim
# 	update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
# 	update-alternatives --set vi /usr/bin/vim

	installVimExtensions
}

installVimExtensions() {
	printSubHeader "Installing vim extensions..."

	mkdir -p ~/.vim/autoload
	mkdir -p ~/.vim/bitmaps
	mkdir -p ~/.vim/bundle
	mkdir -p ~/.vim/colors
	mkdir -p ~/.vim/doc

	ln -s ~/.codisms/repos/vim-pathogen/autoload/pathogen.vim ~/.vim/autoload/pathogen.vim
	ln -s ~/.codisms/repos/solarized/vim-colors-solarized/autoload/togglebg.vim ~/.vim/autoload/togglebg.vim

	ln -s ~/.codisms/repos/solarized/vim-colors-solarized/bitmaps/togglebg.png ~/.vim/bitmaps/togglebg.png

	ln -s ~/.codisms/repos/vim-colors-solarized ~/.vim/bundle/vim-colors-solarized
	#ln -s ~/.codisms/repos/tslime.vim ~/.vim/bundle/tslime.vim
	ln -s ~/.codisms/repos/pgsql.vim ~/.vim/bundle/pgsql.vim
	ln -s ~/.codisms/repos/dbext.vim ~/.vim/bundle/dbext.vim
	#ln -s ~/.vim/repos/vim-neatstatus ~/.vim/bundle/vim-neatstatus
	ln -s ~/.codisms/repos/taboo.vim ~/.vim/bundle/taboo.vim
	ln -s ~/.codisms/repos/vim-go ~/.vim/bundle/vim-go
	ln -s ~/.codisms/repos/vim-ruby ~/.vim/bundle/vim-ruby

	ln -s ~/.codisms/repos/solarized/vim-colors-solarized/colors/solarized.vim ~/.vim/colors/solarized.vim

	ln -s ~/.codisms/repos/dbext.vim/doc/dbext.txt ~/.vim/doc/dbext.txt

	installVimExtensions_YCM
}

installVimExtensions_YCM() {
	printSubHeader "Installing ycm..."

	cd ~/.codisms/repos/YouCompleteMe
	./install.sh --clang-completer --system-libclang --gocode-completer > /dev/null
	cd ~

	ln -s ~/.codisms/repos/YouCompleteMe ~/.vim/bundle/YouCompleteMe
}

# installLibEvent() {
# 	printSubHeader "Installing libevent..."
#
# 	cd ~
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

	cd ~
	echo Cloning tmux...
	#git clone #--quiet https://github.com/tmux/tmux.git
	git clone https://github.com/tmux/tmux.git
	cd tmux
	sh autogen.sh #--quiet > /dev/null
	#./configure --prefix=/usr/local #--quiet > /dev/null
	./configure #--quiet > /dev/null
	make #--quiet > /dev/null
	make install #--quiet > /dev/null
	cd ..
	rm -rf tmux

#  	PATH=$PATH:`find /usr/local/rvm/rubies/ruby-*/bin/ | head -n 1`

# 	gem --update system
	gem install tmuxinator > /dev/null
	#gem install --quiet tmuxinator > /dev/null

	ln -s .codisms/tmuxinator .tmuxinator
	ln -s ~/.codisms/tmux.conf ~/.tmux.conf
}

startServices() {
	printSubHeader "Starting services..."

	startMySql

	ln -s ~/.codisms/bin/tunnels.service /etc/systemd/user/tunnels.service
	systemctl start tunnels.service
	systemctl enable tunnels.service

	ln -s ~/.codisms/bin/vpn-payoff.service /etc/systemd/user/vpn-payoff.service
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

scheduleForNextRun "$HOME/.setup/linux/step4.sh"

printHeader "Finished step 3.  Rebooting..."
# read -p 'Press [Enter] to continue...'

reboot
