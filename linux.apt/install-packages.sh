echo "Installing packages..."

PHP_VERSION=php
JAVA_VERSION=8
#if [ "${UBUNTU_VERSION}" == "14.04" ]; then
#	PHP_VERSION=php5
#	JAVA_VERSION=7
#fi

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
