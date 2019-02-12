#!/bin/bash

# Script will check ALL setup lists

#if [ "$1" == "" ]; then
#	echo "Please provide a package manager"
#	exit 1
#fi

cd scripts

#PACKAGE_FILE_LIST=setup.$1.txt
#if [ ! -f ${PACKAGE_FILE_LIST} ]; then
#	echo "Package install list not found"
#	exit 1
#fi

for file in *.sh; do
	#if ! grep -q "$file" ${PACKAGE_FILE_LIST}; then
	if ! grep -q "$file" setup.*.txt; then
		echo $file
	fi
done

