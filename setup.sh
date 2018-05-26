#!/bin/bash

#set -e

SUDO=$(which sudo 2> /dev/null)
#YUM=$(which yum 2> /dev/null)
#APTGET=$(which apt-get 2> /dev/null)

#if [ "$(which git 2> /dev/null)" == "" ]; then
#	echo "Installing git..."
#	[ "${YUM}" != "" ] && $SUDO yum install -y -q git
#	[ "${APTGET}" != "" ] && $SUDO apt-get install -y -q git
#fi
if [ "$(which git 2> /dev/null)" == "" ]; then
	echo "Could not find git!"
	exit 1
fi

echo "Downloading setup scripts..."
if [ -d ~/.setup ]; then
	rm -rf ~/.setup
fi
git clone https://bitbucket.org/codisms/dev-setup.git ~/.setup
chown -R `whoami`:`whoami` .setup

INSTALL_DIR=
case "$OSTYPE" in
	solaris*) INSTALL_DIR=solaris ;;
	linux*)
		if [ -f /etc/centos-release ]; then
			INSTALL_DIR=linux.yum
		elif [ -n "$(command -v apt-get)" ]; then
			INSTALL_DIR=linux.apt
		elif [ -n "$(command -v yum)" ]; then
			INSTALL_DIR=linux.yum
		fi

		if [ "${INSTALL_DIR}" == "" ]; then
			echo "Unable to find yum or apt-get!"
		fi
		;;
	darwin*) INSTALL_DIR=darwin ;;
	bsd*) INSTALL_DIR=bsd ;;
esac
if [ "${INSTALL_DIR}" == "" ]; then
	echo "Unknown operating system: $OSTYPE"
	exit
fi
if [ ! -f ~/.setup/${INSTALL_DIR}/step1.sh ]; then
	echo "Setup script not found: ${INSTALL_DIR}"
	exit
fi
echo INSTALL_DIR = ${INSTALL_DIR}

if [ -f ~/.bashrc ]; then
	mv ~/.bashrc ~/.bashrc.disabled
fi
if [ -f ~/.bash_profile ]; then
	mv ~/.bash_profile ~/.bash_profile.disabled
fi
if [ -f ~/.profile ]; then
	mv ~/.profile ~/.profile.disabled
fi
touch ~/.profile

echo "Running installer (~/.setup/${INSTALL_DIR}/step1.sh)..."
#find ~/.setup -name \*.sh -exec chmod +x {} \;
~/.setup/${INSTALL_DIR}/step1.sh $HOME `whoami` $1

