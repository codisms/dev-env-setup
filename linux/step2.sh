#!/bin/bash

set -e
cd ~

. ~/.setup/linux/functions

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

downloadRepos() {
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
	ln -s ~/.codisms/pgpass ~/.pgpass
	chmod 600 ~/.pgpass
	chmod 600 ~/.codisms/pgpass
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

installPackages() {
	yum install -y git mercurial bzr \
		gcc gcc-c++ kernel-devel \
		automake cmake make libtool \
		ncurses-devel tcl-devel \
		curlpp libcurl-devel clang ctags wget \
		python python-devel \
		perl perl-devel perl-ExtUtils-ParseXS perl-ExtUtils-CBuilder perl-ExtUtils-Embed \
		bind-utils mutt elinks telnet \
		man zsh \
		mysql mysql-server redis \
		httpd mod_ssl \
		php php-mysql \
		perl-DBD-ODBC freetds \
		libevent-2* libevent-devel-2* \
		postgres-devel yum-utils \
		openssh-clients openconnect \
		sysstat iotop traceroute
		#postgresql94-odbc postgresql-odbc postgresql-devel postgresql94-devel
		#tmux nodejs
		#ruby ruby-devel rubygems
		#lua lua-devel luajit luajit-devel
		#python3 python3-devel \
}

installLanguages() {
	installNode
	installRuby
	installGo
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
	yum install -y nodejs
	npm install --quiet --loglevel warn -g npm > /dev/null
	npm install --quiet --loglevel warn -g grunt-cli gulp-cli nodemon bower json http-server > /dev/null
}

installRuby() {
	printSubHeader "Installing ruby..."

	#rm -rf ~/.gnupg/
	#gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
	curl -sSLO https://rvm.io/mpapis.asc && gpg --import mpapis.asc
	[ -f mpapis.asc ] && rm -f mpapis.asc
	curl -sSL https://get.rvm.io | bash -s stable --rails > /dev/null

	echo Installing v2.2.3...
	rvm install ruby-2.2.3 > /dev/null

	source /usr/local/rvm/scripts/rvm
# 	source /etc/profile
}

installGo() {
	printSubHeader "Installing go..."

	[ -f /usr/local/go1.5.1.linux-amd64.tar.gz ] && rm -f /usr/local/go1.5.1.linux-amd64.tar.gz
	curl -sSL 'https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz' -o /usr/local/go1.5.1.linux-amd64.tar.gz
	[ -d /usr/local/go ] && rm -rf /usr/local/go
	tar -C /usr/local -xzf /usr/local/go1.5.1.linux-amd64.tar.gz

	mkdir -p ~/go/bin
	mkdir -p ~/go/pkg
	mkdir -p ~/go/src/github.com
}

############################################################################################################
# BEGIN
############################################################################################################

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

printHeader "Installing languages..."
installLanguages

# echo
# echo
# echo Generated public key:
# echo
# cat ~/.ssh/id_rsa.pub
# echo
# #read -p 'Press [Enter] to continue...'

scheduleForNextRun "$HOME/.setup/linux/step3.sh"

printHeader "Finished step 2.  Rebooting..."
# read -p 'Press [Enter] to continue...'

reboot
