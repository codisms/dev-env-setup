#!/bin/bash

#set -e

if [ "$(which git 2> /dev/null)" == "" ]; then
	echo "Could not find git!"
	exit 1
fi

echo "Downloading setup scripts..."
if [ -d ${HOME}/.setup ]; then
	rm -rf ${HOME}/.setup
fi
git clone https://github.com/codisms/dev-env-setup.git ${HOME}/.setup
cd ${HOME}/.setup

if [ $VERBOSE -eq 1 ]; then
	export PS4='$0.$LINENO+ '
	set -x
fi

if [ "${BRANCH}" != "" ]; then
	git checkout "${BRANCH}"
fi

cd ${HOME}/.setup
./setup2.sh $@
