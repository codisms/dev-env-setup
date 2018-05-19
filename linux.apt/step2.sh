#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

downloadRepos() {
	echo 'Cloning .codisms; enter bitbucket.org password for "codisms":'
	echo Cloning dev-config...
	retry git clone https://codisms@bitbucket.org/codisms/dev-config.git ${MY_HOME}/.codisms

	printSubHeader "Configuring security..."

	ln -s ${MY_HOME}/.codisms/netrc ${MY_HOME}/.netrc
	chmod 600 ${MY_HOME}/.netrc

	mkdir -p ${MY_HOME}/.ssh
	chmod 700 ${MY_HOME}/.ssh
	mkdir -p ${MY_HOME}/.ssh/controlmasters
	cd ${MY_HOME}/.ssh
	[ -f authorized_keys ] && mv authorized_keys authorized_keys.orig
	find ../.codisms/ssh/ -type f -exec ln -s {} \;
	#chown ${MY_USER}:${MY_USER} *
	chmod 600 *

	sed -i s/codisms@// ${MY_HOME}/.codisms/.git/config

	printSubHeader "Downloading submodules..."

	cd ${MY_HOME}/.codisms
	retry git submodule update --init --recursive

	printSubHeader "Cloning db code..."
	retry git clone https://bitbucket.org/codisms/db.git ${MY_HOME}/db

	printSubHeader "Resetting permissions..."
	resetPermissions
}

#-----------------------------------------------------------------------------------------------------------
# Configuration

configureEnvironment() {
	ln -s ${MY_HOME}/.codisms/repos/dircolors-solarized/dircolors.256dark ${MY_HOME}/.dircolors
	ln -s ${MY_HOME}/.codisms/zshrc ${MY_HOME}/.zshrc
	ln -s ${MY_HOME}/.codisms/gitconfig ${MY_HOME}/.gitconfig
	ln -s ${MY_HOME}/.codisms/elinks ${MY_HOME}/.elinks
	ln -s ${MY_HOME}/.codisms/muttrc ${MY_HOME}/.muttrc
	ln -s ${MY_HOME}/.codisms/ctags ${MY_HOME}/.ctags
	ln -s ${MY_HOME}/.codisms/pgpass ${MY_HOME}/.pgpass
	chmod 600 ${MY_HOME}/.pgpass
	chmod 600 ${MY_HOME}/.codisms/pgpass
}

#-----------------------------------------------------------------------------------------------------------
# Installations

installPackages() {
	apt_get_install git mercurial bzr subversion \
		gcc gpp linux-kernel-headers kernel-package \
		automake cmake make libtool gawk \
		libncurses-dev tcl-dev \
		curl libcurl4-openssl-dev clang ctags \
		python python-dev python-pip python3 python3-dev python3-pip \
		golang \
		perl libperl-dev perl-modules \
		libevent-2* libevent-dev \
		libdbd-odbc-perl freetds-bin freetds-common freetds-dev
	if [ "${UBUNTU_VERSION}" == "14.04" ]; then
		apt_get_install php5-cli php5-mysql openjdk-7-jre
	else
		apt_get_install php-cli php-mysql openjdk-8-jre
	fi

	apt_get_install man htop zsh wget unzip \
		dnsutils mutt elinks telnet \
		redis-server apache2 \
		openssh-client openconnect cifs-utils \
		sysstat iotop traceroute iftop \
		network-manager-vpnc
		#docker docker.io \
		#mariadb mariadb-server \
		#mysql-community-devel mysql-community-server mysql-community-client \
		#postgresql94-odbc postgresql-odbc postgresql-devel postgresql94-devel
		#tmux nodejs
		#lua lua-devel luajit luajit-devel
		#python3 python3-devel \

	#if ! grep -q $group /etc/group; then
	#	groupadd docker
	#fi
	#usermod -aG docker ${MY_USER}
}

installLanguages() {
	installNode
	installRuby
	setUpGo

	if [ ! -d ~/.cache/pip ]; then
		mkdir -p ~/.cache/pip
		chmod 775 ~/.cache/pip
	else
		chmod -R g+rw ~/.cache/pip
		chmod -R o+r ~/.cache/pip
	fi

	# ** Don't do this
	#printSubHeader "Updating pip..."
	#pip install --upgrade pip
}

installNode() {
	printSubHeader "Installing Node.js..."
	curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
	apt_get_install nodejs build-essential

	#echo "Updating npm..."
	#npm install --quiet --loglevel warn -g npm > /dev/null

	# workarounds...
	#mkdir -p ~/.node-gyp/8.9.1
	#mkdir -p /usr/lib/node_modules/@angular/cli/node_modules/node-sass/vendor

	echo "Installing tools..."
	$SUDO npm install --quiet --loglevel warn -g grunt-cli gulp-cli nodemon bower json http-server nodemon jshint eslint typescript > /dev/null
	$SUDO npm install --quiet --unsafe-perm --loglevel warn -g @angular/cli > /dev/null
	$SUDO npm install --quiet --loglevel warn -g ionic > /dev/null
}

installRuby() {
	printSubHeader "Installing Ruby..."
	apt_get_install software-properties-common
	#apt_add_repository ppa:rael-gc/rvm
	#apt_get_update
	#apt_get_install rvm
	#source /etc/profile.d/rvm.sh

	retry gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	curl -sSL https://get.rvm.io | bash -s stable
	source ${MY_HOME}/.rvm/scripts/rvm

	retry rvm install ruby-2.3
	#source /etc/profile.d/rvm.sh
	source ${MY_HOME}/.rvm/scripts/rvm
	retry gem install bundler
}

setUpGo() {
	printSubHeader "Setting up Go directory structure..."
	mkdir -p ${MY_HOME}/go/bin
	mkdir -p ${MY_HOME}/go/pkg
	mkdir -p ${MY_HOME}/go/src/github.com

	printSubHeader "Downloading goimports..."
	cd ${MY_HOME}/go
	GOPATH=`pwd` /usr/local/go/bin/go get golang.org/x/tools/cmd/goimports
	cd ${MY_HOME}
}

############################################################################################################
# BEGIN
############################################################################################################

printHeader "Downloading repos..."
downloadRepos

#-----------------------------------------------------------------------------------------------------------
# Create a SSH key, if needed

# if [ ! -f ${MY_HOME}/.ssh/id_rsa ]; then
#
# 	echo
# 	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# 	echo Generating SSH key...
# 	##read -p 'Press [Enter] to continue...'
#
# 	echo
# 	ssh-keygen -t rsa -N "" -f ${MY_HOME}/.ssh/id_rsa
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
# cat ${MY_HOME}/.ssh/id_rsa.pub
# echo
# #read -p 'Press [Enter] to continue...'

printHeader "Resetting home directory owner..."
resetPermissions

scheduleForNextRun "${MY_HOME}/.setup/linux.apt/step3.sh"

printHeader "Finished step 2.  Rebooting..."
# read -p 'Press [Enter] to continue...'

$SUDO reboot
