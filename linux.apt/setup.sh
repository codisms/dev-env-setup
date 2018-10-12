#!/bin/bash

set -e
SCRIPT_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"
echo "SCRIPT_FOLDER = ${SCRIPT_FOLDER}"
cd ${SCRIPT_FOLDER}

. ./functions

echo "MY_HOME = ${MY_HOME}"
echo "MY_USER = ${MY_USER}"

#resetPermissions
#cleanBoot

HOST_NAME=$1
echo "NEW_HOST_NAME = ${NEW_HOST_NAME}"

while IFS="" read -r line || [ -n "$line" ]; do
	#printf '%s\n' "$p"
	if [ "$line" != "" ] && [[ ! $line =~ ^# ]]; then
		cd ${SCRIPT_FOLDER}

		printHeader "Running script ${line}..." "${line}"
		. ./${line}
	fi
done < setup.apt.txt

exit 1

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

