#!/bin/bash

set -e

# for new 6.6 install in parallels...
# > vi /boot/grub/grub.conf
# Add " vga=0x333"
# > mkdir ~/.ssh
# > chmod 700 ~/.ssh
# > vi ~/.ssh/authorized_keys
# Add public key
# > restorecon -r -vv /root/.ssh
# > vi /etc/ssh/sshd_config
# Uncomment "PubkeyAuthentication yes"
# Set "PasswordAuthentication" to "no"
# > yum -y update
# > reboot


# Jump to "BEGIN"...

printHeader() {
	echo
	echo -------------------------------------------------------------------------------------------------------------------------------------------
	echo $1
	echo
}

printSubHeader() {
	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo $1
	echo
}

downloadRepos() {
	echo Installing git...
	yum -y -q install git
	echo
	echo 'Cloning .codisms; enter bitbucket.org password for "codisms":'
	echo Cloning dev-config...
	git clone --quiet https://codisms@bitbucket.org/codisms/dev-config.git ~/.codisms

	printSubHeader "Configuring security..."

	ln -s ~/.codisms/netrc .netrc
	chmod 600 ~/.netrc

	mkdir -p ~/.ssh
	chmod 700 ~/.ssh
	mkdir -p ~/.ssh/controlmasters
	cd ~/.ssh
	[ -f authorized_keys ] && mv authorized_keys authorized_keys.orig
	find ../.codisms/ssh/ -type f -exec ln -s {} \;
	chmod 600 *
	cd ~

	sed s/codisms@// ~/.codisms/.git/config > ~/.codisms/.git/config

	printSubHeader "Downloading submodules..."

	cd ~/.codisms
	git submodule --quiet update --init --recursive
	cd ~
}

#-----------------------------------------------------------------------------------------------------------
# Configuration

configureEnvironment() {
	ln -s ~/.codisms/repos/dircolors-solarized/dircolors.256dark ~/.dircolors
	ln -s ~/.codisms/zshrc ~/.zshrc
	ln -s ~/.codisms/gitconfig ~/.gitconfig
	ln -s ~/.codisms/elinks ~/.elinks
	ln -s ~/.codisms/ctags ~/.ctags

	[ -f /etc/motd ] && mv /etc/motd /etc/motd.orig
	ln -s ~/.codisms/motd /etc/motd

	echo Installing zsh...
	yum -y -q install zsh

	chsh -s `which zsh`
}

setHostName() {
	echo Setting host name to "$1"...
	[ -f  /etc/sysconfig/network ] && mv -f /etc/sysconfig/network /etc/sysconfig/network.orig

	cat << EOF > /etc/sysconfig/network
echo NETWORKING=yes
echo HOSTNAME=$1
EOF

	echo 127.0.0.1 $1>> /etc/hosts
}

#-----------------------------------------------------------------------------------------------------------
# Installations

postInstall() {
	chmod 755 /root
	[ -d ~/web ] && chown -R apache:apache ~/web

	startServices
}

installPackages() {
	echo Configuration EPEL repository...
	rpm -ivh --quiet http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
	#yum install -y https://centos6.iuscommunity.org/ius-release.rpm

	echo Updating system...
	yum -y -q update

	echo Installing new modules...
	yum install -y -q git mercurial bzr \
		gcc gcc-c++ kernel-devel \
		automake cmake make libtool \
		ncurses-devel tcl-devel \
		curlpp libcurl-devel clang ctags wget \
		python python-devel \
		perl perl-devel perl-ExtUtils-ParseXS perl-ExtUtils-CBuilder perl-ExtUtils-Embed \
		bind-utils mutt elinks telnet \
		man zsh \
		mysql mysql-server \
		httpd mod_ssl \
		php php-mysql \
		perl-DBD-ODBC freetds \
		openssh-clients openconnect
		#postgresql94-odbc postgresql-odbc postgresql-devel postgresql94-devel
		#tmux nodejs
		#ruby ruby-devel rubygems
		#lua lua-devel luajit luajit-devel
		#python3 python3-devel \

	installNode
	installRuby
	installGo
	installPostgres
	installVim
	installTmux

	postInstall
}

installNode() {
	printSubHeader "Installing node..."

# 	git clone --quiet https://github.com/nodejs/node.git
# 	cd node
# 	git checkout --quiet 4.x
# 	./configure --quiet > /dev/null
# 	make --quiet > /dev/null
# 	make install --quiet > /dev/null
# 	cd ..
# 	rm -rf node

	curl -sSL https://rpm.nodesource.com/setup | bash - > /dev/null
	#curl -sSL https://rpm.nodesource.com/setup_4.x | bash - > /dev/null
	#curl -sSL https://rpm.nodesource.com/setup_5.x | bash - > /dev/null
	yum install -q -y nodejs
	npm install --quiet --loglevel warn -g npm
	npm install --quiet --loglevel warn -g grunt-cli gulp-cli nodemon bower json http-server
}

installRuby() {
	printSubHeader "Installing ruby..."

	#rm -rf ~/.gnupg/
	#gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
	curl -sSLO https://rvm.io/mpapis.asc && gpg --import mpapis.asc
	[ -f mpapis.asc ] && rm -f mpapis.asc
	curl -sSL https://get.rvm.io | bash -s stable --rails > /dev/null

	source /usr/local/rvm/scripts/rvm
	source /etc/profile
}

installGo() {
	printSubHeader "Installing go..."

	if [ ! -f /usr/local/go1.5.1.linux-amd64.tar.gz ]; then
		curl -sSL 'https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz' -o /usr/local/go1.5.1.linux-amd64.tar.gz
		tar -C /usr/local -xzf /usr/local/go1.5.1.linux-amd64.tar.gz
	fi

	mkdir -p ~/go/bin
	mkdir -p ~/go/pkg
	mkdir -p ~/go/src/github.com
}

installPostgres() {
	printSubHeader "Installing postgresql..."

	yum install -y -q http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm
	yum install -y -q postgresql94-odbc postgresql94-devel postgresql94 postgresql94-contrib postgresql94-server
	service postgresql-9.4 initdb
	service postgresql-9.4 start
	chkconfig postgresql-9.4 on

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

installLibEvent() {
	printSubHeader "Installing libevent..."

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
	yum install -y -q libevent libevent-devel
}

installTmux() {
	installLibEvent

	printSubHeader "Installing tmux..."

	cd ~
	echo Cloning tmux...
	git clone --quiet https://github.com/tmux/tmux.git
	cd tmux
	sh autogen.sh --quiet > /dev/null
	#./configure --prefix=/usr/local --quiet > /dev/null
	./configure --quiet > /dev/null
	make --quiet > /dev/null
	make install --quiet > /dev/null
	cd ..
	rm -rf tmux

 	PATH=$PATH:`find /usr/local/rvm/rubies/ruby-*/bin/ | head -n 1`

# 	gem --update system
	gem install --quiet tmuxinator > /dev/null

	ln -s .codisms/tmuxinator .tmuxinator
	ln -s ~/.codisms/tmux.conf ~/.tmux.conf
}

startServices() {
	printSubHeader "Starting services..."

	startMySql

	ln -s ~/.codisms/bin/tunnels /etc/init.d/tunnels
	chkconfig tunnels on
	service tunnels start
}

startMySql() {
	service mysqld start
	chkconfig mysqld on
}

#-----------------------------------------------------------------------------------------------------------
# Download code

downloadCode() {
	echo Cloning db... && git clone --quiet https://bitbucket.org/codisms/db.git ~/db
	~/.codisms/get-code.sh
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

printHeader "Downloading repos..."
downloadRepos

#-----------------------------------------------------------------------------------------------------------
# Create a SSH key, if needed

# if [ ! -f ~/.ssh/id_rsa ]; then
#
# 	echo
# 	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# 	echo Generating SSH key...
# 	##read -p 'Press [Enter] to continue...'
#
# 	echo
# 	ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
# fi

#-----------------------------------------------------------------------------------------------------------
# Do it!

printHeader "Configuring environment..."
configureEnvironment

printHeader "Installing packages..."
installPackages

printHeader "Downloading code..."
downloadCode

# echo
# echo
# echo Generated public key:
# echo
# cat ~/.ssh/id_rsa.pub
# echo
# #read -p 'Press [Enter] to continue...'

printHeader "Done.  Rebooting..."
# printHeader "Done.  Ready to reboot"
# read -p 'Press [Enter] to continue...'
# echo

reboot
