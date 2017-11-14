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

	printSubHeader "Resetting permissions..."
	resetPermissions
}

#-----------------------------------------------------------------------------------------------------------
# Configuration

configureEnvironment() {
	ln -s ${MY_HOME}/.codisms/repos/dircolors-solarized/dircolors.256dark ${MY_HOME}/.dir_colors
	ln -s ${MY_HOME}/.codisms/zshrc ${MY_HOME}/.zshrc
	ln -s ${MY_HOME}/.codisms/gitconfig ${MY_HOME}/.gitconfig
	ln -s ${MY_HOME}/.codisms/elinks ${MY_HOME}/.elinks
	ln -s ${MY_HOME}/.codisms/ctags ${MY_HOME}/.ctags
	ln -s ${MY_HOME}/.codisms/pgpass ${MY_HOME}/.pgpass
	chmod 600 ${MY_HOME}/.pgpass
	chmod 600 ${MY_HOME}/.codisms/pgpass
}

#-----------------------------------------------------------------------------------------------------------
# Installations

installPackages() {
	retry $SUDO apt-get install -y git mercurial bzr subversion \
		gcc gpp linux-kernel-headers kernel-package \
		automake cmake make libtool \
		libncurses-dev tcl-dev \
		curl libcurl4-openssl-dev clang ctags \
		python python-dev golang ruby \
		perl libperl-dev perl-modules \
		php-cli php-mysql openjdk-8-jre \
		libdbd-odbc-perl freetds-bin freetds-common freetds-dev \
		libevent-2* libevent-dev

	retry $SUDO apt-get install -y man htop zsh wget unzip \
		dnsutils mutt elinks telnet \
		redis-server apache2 docker \
		openssh-client openconnect \
		sysstat iotop traceroute iftop \
		network-manager-vpnc
		#mariadb mariadb-server \
		#mysql-community-devel mysql-community-server mysql-community-client \
		#postgresql94-odbc postgresql-odbc postgresql-devel postgresql94-devel
		#tmux nodejs
		#ruby ruby-devel rubygems
		#lua lua-devel luajit luajit-devel
		#python3 python3-devel \
}

installLanguages() {
	installNode
	setUpGoDirectories
}

installNode() {
	printSubHeader "Installing Node.js..."
	curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
	sudo apt-get install -y nodejs

	#echo "Updating npm..."
	#npm install --quiet --loglevel warn -g npm > /dev/null

	echo "Installing tools..."
	retry $SUDO npm install --quiet --loglevel warn -g grunt-cli gulp-cli nodemon bower json http-server nodemon jshint eslint > /dev/null
	retry $SUDO npm install --quiet --loglevel warn -g @angular/cli typescript ionic > /dev/null
}

setUpGoDirectories() {
	printSubHeader "Setting up Go directory structure..."
	mkdir -p ${MY_HOME}/go/bin
	mkdir -p ${MY_HOME}/go/pkg
	mkdir -p ${MY_HOME}/go/src/github.com
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

reboot
