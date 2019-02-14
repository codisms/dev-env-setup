#!/bin/bash

#set -e

SECONDS=0

echo "Downloading setup scripts..."
if [ -d ${HOME}/.setup ]; then
	rm -rf ${HOME}/.setup
fi
git clone --depth=1 https://github.com/codisms/dev-env-setup.git ${HOME}/.setup
cd ${HOME}/.setup

. ./functions

PACKAGE_MANAGER=$(get_package_manager)
SCRIPTS_FOLDER="${HOME}/.setup/scripts"
SCRIPT_FILE="${SCRIPTS_FOLDER}/setup.${PACKAGE_MANAGER}.txt"
NEW_HOST_NAME=$(option_value host)
USE_BASH=$(option_set bash)
#DEBUG=${option_set debug}
DEBUG=1

debug "DEBUG = ${DEBUG}"
debug "USE_BASH = ${USE_BASH}"
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

cat <<EOF >> ${HOME}/.profile
PATH=\${PATH}:${HOME}/.local/bin

. ~/.execute_onstart

EOF

cat <<EOF >> ${HOME}/.execute_onstart

#ls -la ~
#date >> ~/log.txt
#echo \$\$ \$BASHPID >> ~/log.txt
#ps aux >> ~/log.txt
#echo PS1 = $PS1 >> ~/log.txt
#echo -- = \$- >> ~/log.txt
#fd=0
#if [ -t "\$fd" ]; then
#	echo fd >> ~/log.txt
#else
#	echo no fd >> ~/log.txt
#fi
#set >> ~/log.txt
#env >> ~/log.txt
#echo "" >> ~/log.txt

let INTERACTIVE=0
#echo -- = \$-
case \$- in
*i*)
	INTERACTIVE=1
	;;
*)
	if [ -t 0 ]; then
	#	echo t = 1
		INTERACTIVE=1
	#else
	#	echo t = 0
	fi
	;;
esac
#echo INTERACTIVE = \${INTERACTIVE}
if [ "\${INTERACTIVE}" == "1" ]; then
	if [ -f ~/.onstart ]; then
		CMD=\`cat ~/.onstart\`
		SUDO=\$(which sudo 2> /dev/null)
		rm -f ~/.onstart
		echo "Executing command: \$CMD \$HOME `whoami`"
		if [ "\$SUDO" == "" ]; then
			read -p 'Press [Enter] key to continue...'
		fi
		\$CMD \$HOME `whoami`
		CMD=
		SUDO=
	else
		#echo "No .onstart"
	fi

	if [ -f ~/.onstart.message ]; then
		cat ~/.onstart.message
		rm ~/.onstart.message
	else
		#echo "No .onstart.message"
	fi
fi

EOF

ls -la ${HOME}

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

