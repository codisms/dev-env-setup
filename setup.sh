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
	return
fi
if [ ! -d ~/.setup/$INSTALL_DIR/setup.sh ]; then
	echo "Setup script not found: $INSTALL_DIR"
	return
fi

echo "Running installer (~/.setup/$INSTALL_DIR/setup.sh)..."
chmod +x ~/.setup/$INSTALL_DIR/*.sh
~/.setup/$INSTALL_DIR/setup.sh $1

