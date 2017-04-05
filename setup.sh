#!/bin/bash

SUDO=$(which sudo 2> /dev/null)

if [ "$(which git 2> /dev/null)" == "" ]; then
	echo "Installing git..."
	$SUDO yum install -y -q git
fi

echo "Downloading setup scripts..."
git clone --quiet -b centos7 https://bitbucket.org/codisms/dev-setup.git ~/.setup
chown -R `whoami`:`whoami` .setup

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

cat <<EOF >> ~/.bashrc
export PATH=\${PATH}:/usr/local/go/bin

if [ -f ~/.onstart ]; then
        CMD=\`cat ~/.onstart\`
	SUDO=\$(which sudo 2> /dev/null)
        rm -f ~/.onstart
        echo "Executing command: \$SUDO \$CMD \$HOME `whoami`"
	if [ "\$SUDO" == "" ]; then
		read -p 'Press [Enter] key to continue...'
	fi
        \$SUDO \$CMD \$HOME `whoami`
        CMD=
	SUDO=
fi

EOF

echo "Running installer (~/.setup/$INSTALL_DIR/step1.sh)..."
#find ~/.setup -name \*.sh -exec chmod +x {} \;
$SUDO ~/.setup/$INSTALL_DIR/step1.sh $HOME `whoami` $1

