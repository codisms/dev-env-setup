#!/bin/bash

#set -e

cd ${HOME}/.setup

. ./functions

PACKAGE_MANAGER=$(get_package_manager)
SCRIPTS_FOLDER="${HOME}/.setup/scripts"
SCRIPT_FILENAME=$1
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

if [ ! -f ${SCRIPT_FILENAME} ]; then
	echo "Setup script not found: ${SCRIPT_FILENAME}"
	exit
fi

set -e

cd ${SCRIPTS_FOLDER}
. ./functions.${PACKAGE_MANAGER}

#resetPermissions
#cleanBoot


printHeader "Running script ${SCRIPT_FILENAME}..." "${SCRIPT_FILENAME}"
. ./${SCRIPT_FILENAME}

printHeader "Resetting environment and permissions..." "reset"
cd ${HOME}/.dotfiles
git checkout -- zshrc

reloadEnvironment
resetPermissions
cleanBoot

