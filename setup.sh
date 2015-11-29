#!/bin/bash

echo "Installing git..."
yum install -y -q git

git clone https://bitbucket.org/codisms/dev-setup.git ~/.setup

INSTALL_DIR=
case "$OSTYPE" in
	solaris*) INSTALL_DIR=solaris ;;
	linux*) INSTALL_DIR=linux ;;
	darwin*) INSTALL_DIR=darwin ;;
	bsd*) INSTALL_DIR=bsd ;;
esac
if [ "$INSTALL_DIR" == "" ]; then
	echo "Unknown operating system: $OSTYPE"
	exit
fi
if [ ! -f ~/.setup/$INSTALL_DIR/step1.sh ]; then
	echo "Setup script not found: $INSTALL_DIR"
	exit
fi

echo "Running installer (~/.setup/$INSTALL_DIR/step1.sh)..."
chmod +x ~/.setup/$INSTALL_DIR/*.sh
~/.setup/$INSTALL_DIR/step1.sh $1

