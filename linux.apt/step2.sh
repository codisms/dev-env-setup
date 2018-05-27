#!/bin/bash

echo 'step2.sh'

echo '*1'
set -e
echo '*2'
cd "$( dirname "${BASH_SOURCE[0]}" )"
echo '*3'

. ./functions
echo '*4'

downloadRepos() {
	printHeader "Downloading repos..." "dl-repos"

	printSubHeader "Cloning dev-config..."
	echo 'Cloning .codisms; enter bitbucket.org password for "codisms":'
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
	printHeader "Configuring environment..." "config-env"

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
	printHeader "Installing packages..." "install-pkg"

	PHP_VERSION=php
	JAVA_VERSION=8
	if [ "${UBUNTU_VERSION}" == "14.04" ]; then
		PHP_VERSION=php5
		JAVA_VERSION=7
	fi

	apt_get_install git mercurial bzr subversion \
		gcc gpp linux-kernel-headers kernel-package \
		automake cmake make libtool gawk \
		libncurses-dev tcl-dev \
		curl libcurl4-openssl-dev clang ctags \
		python python-dev python-pip python3 python3-dev python3-pip \
		perl libperl-dev perl-modules \
		libevent-2* libevent-dev \
		libdbd-odbc-perl freetds-bin freetds-common freetds-dev \
		man htop zsh wget unzip \
		dnsutils mutt elinks telnet \
		redis-server apache2 \
		openssh-client openconnect cifs-utils \
		sysstat iotop traceroute iftop \
		network-manager-vpnc \
		${PHP_VERSION}-cli ${PHP_VERSION}-mysql openjdk-${JAVA_VERSION}-jre
		#docker docker.io \
		#lua lua-devel luajit luajit-devel

	#if ! grep -q $group /etc/group; then
	#	groupadd docker
	#fi
	#usermod -aG docker ${MY_USER}

	reloadEnvironment
}

installLanguages() {
	printHeader "Installing languages..." "install-lang"

	installNode
	installRuby
	installGo
	updatePip
}

updatePip() {
	printHeader "Setting up pip..." "pip"
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

	reloadEnvironment
}

installNode() {
	printHeader "Installing Node.js..." "node"
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
	echo 'export NVM_DIR="$HOME/.nvm"' >> ${MY_HOME}/.profile
	echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ${MY_HOME}/.profile
	reloadEnvironment
	nvm install stable

	printSubHeader "Installing tools..."
	npm install --quiet -g grunt-cli gulp-cli nodemon bower json http-server nodemon jshint eslint typescript tslint > /dev/null
	npm install --quiet -g @angular/cli > /dev/null
	npm install --quiet -g ionic > /dev/null

	#curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
	#apt_get_install nodejs build-essential

	##echo "Updating npm..."
	##npm install --quiet --loglevel warn -g npm > /dev/null

	## workarounds...
	##mkdir -p ~/.node-gyp/8.9.1
	##mkdir -p /usr/lib/node_modules/@angular/cli/node_modules/node-sass/vendor

	#printSubHeader "Installing tools..."
	#$SUDO npm install --quiet --loglevel warn -g grunt-cli gulp-cli nodemon bower json http-server nodemon jshint eslint typescript > /dev/null
	#$SUDO npm install --quiet --unsafe-perm --loglevel warn -g @angular/cli > /dev/null
	#$SUDO npm install --quiet --loglevel warn -g ionic > /dev/null

	reloadEnvironment
}

installRuby() {
	printHeader "Installing Ruby..." "ruby"
	apt_get_install software-properties-common
	#apt_add_repository ppa:rael-gc/rvm
	#apt_get_update
	#apt_get_install rvm
	#source /etc/profile.d/rvm.sh

	printSubHeader "Downloading GPG keys..."
	retry gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	curl -sSL https://get.rvm.io | bash -s stable
	reloadEnvironment
	#source ${MY_HOME}/.rvm/scripts/rvm

	printSubHeader "Downloading and installying Ruby..."
	retry rvm install ruby-2.3
	#source /etc/profile.d/rvm.sh
	#source ${MY_HOME}/.rvm/scripts/rvm
	reloadEnvironment

	printSubHeader "Running bundler..."
	retry gem install bundler

	reloadEnvironment
}

installGo() {
	printHeader "Setting up Go..." "go"

	curl https://dl.google.com/go/go1.10.2.linux-amd64.tar.gz > /tmp/go.tar.gz
	$SUDO tar -C /usr/local -xzf /tmp/go.tar.gz
	#export PATH=${PATH}:/usr/local/go/bin
	#export GOPATH=${MY_HOME}/go
	echo "export PATH=\${PATH}:/usr/local/go/bin" >> ~/.profile
	echo "export GOPATH=${MY_HOME}/go" >> ~/.profile
	reloadEnvironment

	printSubHeader "Setting up Go directory structure..."
	mkdir -p ${MY_HOME}/go/bin
	mkdir -p ${MY_HOME}/go/pkg
	mkdir -p ${MY_HOME}/go/src/github.com

	printSubHeader "Downloading goimports..."
	cd ${MY_HOME}/go
	GOPATH=`pwd` go get golang.org/x/tools/cmd/goimports
	cd ${MY_HOME}

	reloadEnvironment
}

############################################################################################################
# BEGIN
############################################################################################################

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

echo '*5'
configureEnvironment
installPackages
installLanguages

reloadEnvironment

# echo
# echo
# echo Generated public key:
# echo
# cat ${MY_HOME}/.ssh/id_rsa.pub
# echo
# #read -p 'Press [Enter] to continue...'

#printHeader "Resetting home directory owner..." "reset-perm"
#resetPermissions
#
#scheduleForNextRun "${MY_HOME}/.setup/linux.apt/step3.sh"
#
#printHeader "Finished step 2.  \e[5mRebooting\e[25m..." "reboot"
#echo -ne '\007'
## read -p 'Press [Enter] to continue...'
#
#$SUDO reboot

echo '---'
"${MY_HOME}/.setup/linux.apt/step3.sh"
echo '---'

