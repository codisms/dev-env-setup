#!/bin/bash

#set -e

SECONDS=0

echo "Downloading setup scripts..."
if [ -d ${HOME}/.setup ]; then
	rm -rf ${HOME}/.setup
fi
git clone --depth=1 https://bitbucket.org/codisms/dev-setup.git ${HOME}/.setup
cd ${HOME}/.setup

. ./functions

PACKAGE_MANAGER=$(get_package_manager)
SCRIPTS_FOLDER="${HOME}/.setup/scripts"
SCRIPT_FILE="${SCRIPTS_FOLDER}/setup.${PACKAGE_MANAGER}.txt"
NEW_HOST_NAME=$(option_value host)
#DEBUG=${option_set debug}
DEBUG=1

debug "DEBUG = ${DEBUG}"
debug "HOME = ${HOME}"
debug "USER = ${USER}"
debug "PACKAGE_MANAGER = ${PACKAGE_MANAGER}"
debug "SCRIPTS_FOLDER = ${SCRIPTS_FOLDER}"
debug "SCRIPT_FILE = ${SCRIPT_FILE}"
debug "NEW_HOST_NAME = ${NEW_HOST_NAME}"

if [ "${PACKAGE_MANAGER}" == "" ]; then
	echo "Unknown operating system: $OSTYPE"
	exit
fi

if [ "$(which git 2> /dev/null)" == "" ]; then
	echo "Could not find git!"
	exit 1
fi

if [ ! -f ${SCRIPT_FILE} ]; then
	echo "Setup script not found: ${SCRIPT_FILE}"
	exit
fi

#printHeader "Pre-install..." "pre-install"

[ -f ${HOME}/.bashrc ] && mv ${HOME}/.bashrc ${HOME}/.bashrc.disabled
[ -f ${HOME}/.bash_profile ] && mv ${HOME}/.bash_profile ${HOME}/.bash_profile.disabled
[ -f ${HOME}/.profile ] && mv ${HOME}/.profile ${HOME}/.profile.disabled

echo "PATH=\${PATH}:${HOME}/.local/bin" > ${HOME}/.profile

set -e

cd ${SCRIPTS_FOLDER}
. ./functions.${PACKAGE_MANAGER}

#resetPermissions
#cleanBoot

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

printHeader "Resetting environment and permissions..." "reset"
cd ${HOME}/.dotfiles
git checkout -- zshrc

reloadEnvironment
resetPermissions
cleanBoot

HOURS=$(($SECONDS / 3600))
if [ $HOURS -eq 0 ]; then
	HOURS=
else
	HOURS="${HOURS}h "
fi
MINUTES=$((($SECONDS / 60) % 60))
if [ $MINUTES -eq 0 ]; then
	MINUTES=
else
	MINUTES="${MINUTES}m "
fi
SECONDS=$(($SECONDS % 60))

printHeader "Done.  \e[5mRebooting\e[25m for the final time..." "reboot"
echo -e "\e[97mScript run time: ${HOURS}${MINUTES}${SECONDS}s\e[0m"
echo -ne '\007'

$SUDO reboot

