#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

. ./functions

#-----------------------------------------------------------------------------------------------------------
# Installations

installFonts() {
	retry pip install --user powerline-status

	## https://gist.github.com/renshuki/3cf3de6e7f00fa7e744a
	#mkdir -p ~/.fonts
	#mkdir -p ~/.config/fontconfig/conf.d

	#curl https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -o ~/.fonts/PowerlineSymbols.otf -L
	#curl https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -o ~/.config/fontconfig/conf.d/10-powerline-symbols.conf -L

	#fc-cache -vf ~/.fonts/
}

postInstall() {
	$SUDO chmod 755 ${MY_HOME}
	[ -d ${MY_HOME}/web ] && chown -R apache:apache ${MY_HOME}/web

	startServices
}

installPackages() {
	installPostgres
	installVim
	installTmux

	postInstall
}

installPostgres() {
	printSubHeader "Installing postgresql..."

	#apt_get_install postgresql-9.5 postgresql-client-9.5 postgresql-common postgresql-contrib-9.5 postgresql-doc-9.5 postgresql-server-dev-9.5
	apt_get_install postgresql postgresql-contrib postgresql postgresql-client
	#/usr/pgsql-9.6/bin/postgresql96-setup initdb

	echo ""
	echo "To start PostgreSQL: systemctl start postgresql.service"
	echo "To have PostgreSQL start on boot: systemctl enable postgresql.service"
	echo ""

	ln -s ${MY_HOME}/.codisms/psqlrc ${MY_HOME}/.psqlrc
}

installVim() {
	printSubHeader "Installing vim..."

	$SUDO ${MY_HOME}/.codisms/bin/install-vim --pwd=${MY_HOME} --build
}

installTmux() {
	printSubHeader "Installing libevent 2.x..."
	apt_get_install libevent-2* libevent-dev

	printSubHeader "Installing tmux..."

	$SUDO ${MY_HOME}/.codisms/bin/install-tmux --version=2.6 --pwd=${MY_HOME} --build
}

startServices() {
	printSubHeader "Starting services..."

	#startMySql

	if hash ufw 2>/dev/null; then
		echo Disabling firewalld...
		$SUDO ufw disable
	fi
}

startMySql() {
	$SUDO systemctl start mysqld.service
	$SUDO systemctl enable mysqld.service
}

downloadCode() {
	cd ${MY_HOME}/go
	GOPATH=`pwd` /usr/local/go/bin/go get golang.org/x/tools/cmd/goimports
	cd ${MY_HOME}

	echo Cloning db...
	retry git clone https://bitbucket.org/codisms/db.git ${MY_HOME}/db
	${MY_HOME}/.codisms/get-code.sh
}

finalConfigurations() {
	echo "Setting motd..."
	[ -f /etc/motd ] && $SUDO mv /etc/motd /etc/motd.orig
	$SUDO ln -s ${MY_HOME}/.codisms/motd /etc/motd

	echo "Setting zsh as default shell..."
	[ -f /etc/ptmp ] && $SUDO rm -f /etc/ptmp
	$SUDO chsh -s `which zsh` ${MY_USER}

	echo "Setting crontab jobs ${MY_USER} ${MY_HOME}..."
	set +e
	(crontab -u ${MY_USER} -l 2>/dev/null; \
		echo "0 5 * * * ${MY_HOME}/.codisms/bin/crontab-daily"; \
		echo "5 5 * * 1 ${MY_HOME}/.codisms/bin/crontab-weekly"; \
		echo "15 5 1 * * ${MY_HOME}/.codisms/bin/crontab-monthly") | crontab -u ${MY_USER} -
	set -e
}


############################################################################################################
# BEGIN
############################################################################################################

printHeader "Installing fonts..."
installFonts

printHeader "Installing packages..."
installPackages

printHeader "Making final configuration changes..."
finalConfigurations

read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
	printHeader "Downloading code..."
	downloadCode
	rsync -avzhe ssh --progress dev.codisms.com:/root/ /root/
fi

printHeader "Resetting home directory owner..."
resetPermissions

printHeader "Done.  Rebooting for the final time..."
# read -p 'Press [Enter] to continue...'
$SUDO reboot

