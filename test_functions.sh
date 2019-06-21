#!/bin/bash

#set -e

. ./functions

PACKAGE_MANAGER=$(get_package_manager)
SCRIPTS_FOLDER="${HOME}/.setup/scripts"
SCRIPT_FILE="${SCRIPTS_FOLDER}/setup.${PACKAGE_MANAGER}.txt"
NEW_HOST_NAME=$(option_value host)
BRANCH=$(option_value branch)
USE_BASH=$(option_set bash)
#DEBUG=${option_set debug}
DEBUG=1
VERBOSE=${option_set verbose}

debug "DEBUG = ${DEBUG}"
debug "VERBOSE = ${VERBOSE}"
debug "BRANCH = ${BRANCH}"
debug "USE_BASH = ${USE_BASH}"
debug "HOME = ${HOME}"
debug "USER = ${USER}"
debug "PACKAGE_MANAGER = ${PACKAGE_MANAGER}"
debug "SCRIPTS_FOLDER = ${SCRIPTS_FOLDER}"
debug "SCRIPT_FILE = ${SCRIPT_FILE}"
debug "NEW_HOST_NAME = ${NEW_HOST_NAME}"

