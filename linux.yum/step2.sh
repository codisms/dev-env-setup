#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

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

setHostName() {
	echo Setting host name to "$1"...
	[ -f  /etc/sysconfig/network ] && $SUDO mv -f /etc/sysconfig/network /etc/sysconfig/network.orig

	$SUDO cat << EOF > /etc/sysconfig/network
echo NETWORKING=yes
echo HOSTNAME=$1
EOF

	$SUDO echo 127.0.0.1 $1>> /etc/hosts
}

#-----------------------------------------------------------------------------------------------------------
# Installations

installPackages() {
	#yum remove postgresql postgresql-devel postgresql-libs postgresql-contrib

	$SUDO yum install -y git mercurial bzr \
		gcc gcc-c++ kernel-devel \
		automake cmake make libtool bc \
		ncurses-devel tcl-devel \
		libcurl-devel clang ctags wget unzip \
		python python-devel python2-pip python34 python34-pip python34-devel\
		golang \
		perl perl-devel perl-ExtUtils-ParseXS perl-ExtUtils-CBuilder perl-ExtUtils-Embed \
		bind-utils mutt elinks telnet \
		man htop zsh \
		redis \
		httpd mod_ssl \
		php php-mysql \
		java-1.8.0-openjdk \
		perl-DBD-ODBC freetds \
		libevent-2* libevent-devel-2* \
		yum-utils \
		openssh-clients openconnect cifs-utils \
		docker \
		sysstat iotop traceroute
		#mariadb mariadb-server \
		#mysql-community-devel mysql-community-server mysql-community-client \
		#postgresql94-odbc postgresql-odbc postgresql-devel postgresql94-devel
		#tmux nodejs
		#lua lua-devel luajit luajit-devel
		#python3 python3-devel \

	if ! grep -q $group /etc/group; then
		$SUDO groupadd docker
	fi
	$SUDO usermod -aG docker ${MY_USER}
}

installLanguages() {
	installNode
	installRuby
	setUpGoDirectories

	printSubHeader "Updating pip..."

	if [ ! -d ~/.cache/pip ]; then
		mkdir -p ~/.cache/pip
		chmod 775 ~/.cache/pip
	else
		chmod -R g+rw ~/.cache/pip
		chmod -R o+r ~/.cache/pip
	fi
	pip install --upgrade pip
}

installNode() {
	printSubHeader "Installing Node.js..."
	#curl -sSL https://rpm.nodesource.com/setup_7.x | bash - > /dev/null
	$SUDO yum install -y nodejs

	#echo "Updating npm..."
	#npm install --quiet --loglevel warn -g npm > /dev/null

	echo "Installing tools..."
	#if [ -d /usr/lib/node_modules ]; then
	#	$SUDO chmod -R g+w /usr/lib/node_modules
	#fi
	$SUDO npm install --quiet --loglevel warn -g grunt-cli gulp-cli nodemon bower json http-server nodemon jshint eslint typescript > /dev/null
	$SUDO npm install --quiet --unsafe-perm --loglevel warn -g @angular/cli > /dev/null
	$SUDO npm install --quiet --loglevel warn -g ionic > /dev/null
}

installRuby() {
#	apt_get_install software-properties-common
#	$SUDO apt-add-repository -y ppa:rael-gc/rvm
#	apt_get_update
#	apt_get_install rvm
#	source /etc/profile.d/rvm.sh
#	echo "export rvm_max_time_flag=20" >> ~/.rvmrc
#	rvm install ruby-2.3.4
#	source /etc/profile.d/rvm.sh
#	gem install bundler
	echo Ruby needs to be installed!
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

scheduleForNextRun "${MY_HOME}/.setup/linux.yum/step3.sh"

printHeader "Finished step 2.  Rebooting..."
# read -p 'Press [Enter] to continue...'

$SUDO reboot
