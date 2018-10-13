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
if [ -d ${HOME}/.setup ]; then
	rm -rf ${HOME}/.setup
fi
git clone --depth=1 https://bitbucket.org/codisms/dev-setup.git ${HOME}/.setup
chown -R `whoami`:`whoami` .setup

PACKAGE_MANAGER=
case "$OSTYPE" in
	solaris*) PACKAGE_MANAGER=solaris ;;
	linux*)
		if [ -f /etc/centos-release ]; then
			PACKAGE_MANAGER=yum
		elif [ -n "$(command -v apt-get)" ]; then
			PACKAGE_MANAGER=apt
		elif [ -n "$(command -v yum)" ]; then
			PACKAGE_MANAGER=yum
		fi

		if [ "${PACKAGE_MANAGER}" == "" ]; then
			echo "Unable to find yum or apt-get!"
		fi
		;;
	darwin*) PACKAGE_MANAGER=darwin ;;
	bsd*) PACKAGE_MANAGER=bsd ;;
esac
if [ "${PACKAGE_MANAGER}" == "" ]; then
	echo "Unknown operating system: $OSTYPE"
	exit
fi
SCRIPTS_FOLDER="${HOME}/.setup/scripts"
RIPT_FILE="${SCRIPTS_FOLDER}/setup.${PACKAGE_MANAGER}.txt"
if [ ! -f ${SCRIPT_FILE} ]; then
	echo "Setup script not found: ${SCRIPT_FILE}"
	exit
fi
echo "SCRIPTS_FOLDER = ${SCRIPTS_FOLDER}"
echo "SCRIPT_FILE = ${SCRIPT_FILE}"

if [ -f ${HOME}/.bashrc ]; then
	mv ${HOME}/.bashrc ${HOME}/.bashrc.disabled
fi
if [ -f ${HOME}/.bash_profile ]; then
	mv ${HOME}/.bash_profile ${HOME}/.bash_profile.disabled
fi
if [ -f ${HOME}/.profile ]; then
	mv ${HOME}/.profile ${HOME}/.profile.disabled
fi
echo "PATH=\${PATH}:${HOME}/.local/bin" > ${HOME}/.profile

MY_HOME=${HOME}
MY_USER=$(whoami)

cd ${SCRIPTS_FOLDER}
. ./functions.${PACKAGE_MANAGER}

echo "MY_HOME = ${MY_HOME}"
echo "MY_USER = ${MY_USER}"

#resetPermissions
#cleanBoot

HOST_NAME=$1
echo "NEW_HOST_NAME = ${NEW_HOST_NAME}"

echo "Running install script (${SCRIPT_FILE})..."
while IFS="" read -r line || [ -n "$line" ]; do
	#printf '%s\n' "$p"
	if [ "$line" != "" ] && [[ ! $line =~ ^# ]]; then
		cd ${SCRIPTS_FOLDER}

		printHeader "Running script ${line}..." "${line}"
		. ./${line}
	fi
done < setup.apt.txt

#read -p "Download pre-defined code projects? (y/n) " -n 1 -r
#echo
#if [[ $REPLY =~ ^[Yy]$ ]]; then
#	printHeader "Downloading code..." "dl-code"
#	cd ~
#	~/.codisms/get-code.sh
#	#rsync -avzhe ssh --progress dev.codisms.com:/root/ /root/
#fi

cd ${MY_HOME}/.codisms
git checkout -- zshrc

reloadEnvironment
resetPermissions
cleanBoot

printHeader "Done.  \e[5mRebooting\e[25m for the final time..." "reboot"
echo -ne '\007'

$SUDO reboot

