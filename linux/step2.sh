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
	git clone https://codisms@bitbucket.org/codisms/dev-config.git ${MY_HOME}/.codisms

	printSubHeader "Configuring security..."

	ln -s ${MY_HOME}/.codisms/netrc ${MY_HOME}/.netrc
	chmod 600 ${MY_HOME}/.netrc

	mkdir -p ${MY_HOME}/.ssh
	chmod 700 ${MY_HOME}/.ssh
	mkdir -p ${MY_HOME}/.ssh/controlmasters
	cd ${MY_HOME}/.ssh
	[ -f authorized_keys ] && mv authorized_keys authorized_keys.orig
	find ../.codisms/ssh/ -type f -exec ln -s {} \;
	chmod 600 *

	sed -i s/codisms@// ${MY_HOME}/.codisms/.git/config

	printSubHeader "Downloading submodules..."

	cd ${MY_HOME}/.codisms
	git submodule update --init --recursive
}

#-----------------------------------------------------------------------------------------------------------
# Configuration

configureEnvironment() {
	ln -s ${MY_HOME}/.codisms/repos/dircolors-solarized/dircolors.256dark ${MY_HOME}/.dircolors
	ln -s ${MY_HOME}/.codisms/zshrc ${MY_HOME}/.zshrc
	ln -s ${MY_HOME}/.codisms/gitconfig ${MY_HOME}/.gitconfig
	ln -s ${MY_HOME}/.codisms/elinks ${MY_HOME}/.elinks
	ln -s ${MY_HOME}/.codisms/ctags ${MY_HOME}/.ctags
	ln -s ${MY_HOME}/.codisms/pgpass ${MY_HOME}/.pgpass
	chmod 600 ${MY_HOME}/.pgpass
	chmod 600 ${MY_HOME}/.codisms/pgpass
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
	#yum remove postgresql postgresql-devel postgresql-libs postgresql-contrib

	yum install -y git mercurial bzr \
		gcc gcc-c++ kernel-devel \
		automake cmake make libtool \
		ncurses-devel tcl-devel \
		libcurl-devel clang ctags wget unzip \
		python python-devel \
		perl perl-devel perl-ExtUtils-ParseXS perl-ExtUtils-CBuilder perl-ExtUtils-Embed \
		bind-utils mutt elinks telnet \
		man htop zsh \
		mariadb mariadb-server \
		redis \
		httpd mod_ssl \
		php php-mysql java-1.8.0-openjdk \
		perl-DBD-ODBC freetds \
		libevent-2* libevent-devel-2* \
		yum-utils \
		openssh-clients openconnect \
		docker \
		sysstat iotop traceroute
		#mysql-community-devel mysql-community-server mysql-community-client \
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

	#curl -sSL https://rpm.nodesource.com/setup | bash - > /dev/null
	#curl -sSL https://rpm.nodesource.com/setup_0.12 | bash - > /dev/null
	#curl -sSL https://rpm.nodesource.com/setup_4.x | bash - > /dev/null
	#curl -sSL https://rpm.nodesource.com/setup_5.x | bash - > /dev/null
	#curl -sSL https://rpm.nodesource.com/setup_6.x | bash - > /dev/null
	curl -sSL https://rpm.nodesource.com/setup_7.x | bash - > /dev/null
	yum install --nogpgcheck -y nodejs
	npm install --quiet --loglevel warn -g npm > /dev/null
	npm install --quiet --loglevel warn -g grunt-cli gulp-cli nodemon bower json http-server nodemon jshint eslint > /dev/null
}

installRuby() {
	printSubHeader "Installing ruby..."

	cd ${MY_HOME}
	#rm -rf ${MY_HOME}/.gnupg/
	#gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
	curl -sSLO https://rvm.io/mpapis.asc && gpg --import mpapis.asc
	[ -f mpapis.asc ] && rm -f mpapis.asc
	curl -sSL https://get.rvm.io | bash -s stable --rails > /dev/null

	source /usr/local/rvm/scripts/rvm
# 	source /etc/profile

	RVM=`which rvm`
	if [ "$RVM" == "" ]; then
		RVM=/usr/local/rvm/bin/rvm
	fi
	echo RVM=$RVM

	echo Installing v2.2.3...
	$RVM install ruby-2.2.3 > /dev/null
	$RVM use 2.2.3 --default
}

installGo() {
	printSubHeader "Installing go..."

	[ -f /usr/local/go1.8.linux-amd64.tar.gz ] && rm -f /usr/local/go1.8.linux-amd64.tar.gz
	curl -sSL 'https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz' -o /usr/local/go1.8.linux-amd64.tar.gz
	[ -d /usr/local/go ] && rm -rf /usr/local/go
	tar -C /usr/local -xzf /usr/local/go1.8.linux-amd64.tar.gz

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

scheduleForNextRun "${MY_HOME}/.setup/linux/step3.sh"

printHeader "Finished step 2.  Rebooting..."
# read -p 'Press [Enter] to continue...'

reboot
