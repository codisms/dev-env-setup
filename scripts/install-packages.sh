echo "Installing packages..."

PHP_VERSION=php
JAVA_VERSION=8
#if [ "${UBUNTU_VERSION}" == "14.04" ]; then
#	PHP_VERSION=php5
#	JAVA_VERSION=7
#fi

apt_get_install git mercurial bzr subversion \
	gcc gpp linux-kernel-headers kernel-package \
	automake cmake make libtool gawk gdb \
	libncurses-dev tcl-dev \
	curl libcurl4-openssl-dev clang ctags \
	python3 python3-dev python3-pip \
	perl libperl-dev perl-modules \
	libevent-2* libevent-dev \
	libdbd-odbc-perl freetds-bin freetds-common freetds-dev \
	man htop zsh wget unzip \
	net-tools dnsutils mutt elinks telnet \
	apt-transport-https gnupg2 \
	redis-server apache2 pv \
	openssh-client openconnect cifs-utils \
	sysstat iotop traceroute iftop \
	network-manager-vpnc aria2 \
	figlet rename \
	${PHP_VERSION}-cli ${PHP_VERSION}-mysql openjdk-${JAVA_VERSION}-jre
	#docker docker.io \
	#lua lua-devel luajit luajit-devel

#if ! grep -q $group /etc/group; then
#	groupadd docker
#fi
#usermod -aG docker ${USER}

reloadEnvironment

printSubHeader "Configuring apache modules"
$SUDO a2enmod proxy proxy_http proxy_wstunnel rewrite auth_basic proxy_balancer proxy_html proxy_connect ssl xml2enc substitute macro include headers

