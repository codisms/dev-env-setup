#!/bin/bash

#set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

#. ./functions
resetPermissions
cleanBoot

#-----------------------------------------------------------------------------------------------------------
# Installations

installFonts() {
	printHeader "Installing fonts..." "fonts"
	retry pip install --user powerline-status

	## https://gist.github.com/renshuki/3cf3de6e7f00fa7e744a
	#mkdir -p ~/.fonts
	#mkdir -p ~/.config/fontconfig/conf.d

	#curl https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -o ~/.fonts/PowerlineSymbols.otf -L
	#curl https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -o ~/.config/fontconfig/conf.d/10-powerline-symbols.conf -L

	#fc-cache -vf ~/.fonts/
}

installTools() {
	installAwsCli
	installCertbot
}

installCertbot() {
	$SUDO apt_add_repository ppa:certbot/certbot
	$SUDO apt_get_update
	$SUDO apt_get_install python-certbot-apache python-certbot-nginx
}

installAwsCli() {
	retry pip install awscli --upgrade --user
}

postInstall() {
	$SUDO chmod 755 ${MY_HOME}
	[ -d ${MY_HOME}/web ] && chown -R apache:apache ${MY_HOME}/web

	printSubHeader "Configuring apache modules"
	$SUDO a2enmod proxy proxy_http proxy_wstunnel rewrite auth_basic proxy_balancer proxy_html proxy_connect ssl xml2enc substitute

	startServices
}

installPackages() {
	printHeader "Installing packages..." "install-pkg"
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
	$SUDO PATH="${PATH}" ${MY_HOME}/.codisms/bin/install-vim --pwd=${MY_HOME} --build
}

installTmux() {
	printSubHeader "Installing libevent 2.x..."
	apt_get_install libevent-2* libevent-dev

	printSubHeader "Installing tmux..."
	$SUDO PATH="${PATH}" ${MY_HOME}/.codisms/bin/install-tmux --version=2.6 --pwd=${MY_HOME} --build
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
	printSubHeader "Starting MySQL services..."
	$SUDO systemctl start mysqld.service
	$SUDO systemctl enable mysqld.service
}

finalCleanup() {
	printHeader "Removing unused packages...", "autoremove"
	apt_get_autoremove
}

finalConfigurations() {
	printHeader "Making final configuration changes..." "final-config"
	printSubHeader "Setting motd..."
	[ -f /etc/motd ] && $SUDO mv /etc/motd /etc/motd.orig
	$SUDO ln -s ${MY_HOME}/.codisms/motd /etc/motd

	printSubHeader "Setting zsh as default shell..."
	[ -f /etc/ptmp ] && $SUDO rm -f /etc/ptmp
	$SUDO chsh -s `which zsh` ${MY_USER}

	printSubHeader "Setting crontab jobs ${MY_USER} ${MY_HOME}..."
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

reloadEnvironment

installFonts
installTools
installPackages
finalConfigurations

#scheduleForNextRun '#!/bin/bash
#
#read -p "Download pre-defined code projects? (y/n) " -n 1 -r
#echo
#if [[ $REPLY =~ ^[Yy]$ ]]; then
#	printHeader "Downloading code..." "dl-code"
#	cd ~
#	~/.codisms/get-code.sh
#	#rsync -avzhe ssh --progress dev.codisms.com:/root/ /root/
#fi
#'
#chmod +x ${MY_HOME}/.onstart

cd ${MY_HOME}/.codisms
git checkout -- zshrc

printHeader "Resetting home directory owner..." "reset-perm"
resetPermissions

cleanBoot
if [ -f ${MY_HOME}/.execute_onstart ]; then
	rm ${MY_HOME}/.execute_onstart
fi

printHeader "Done.  \e[5mRebooting\e[25m for the final time..." "reboot"
echo -ne '\007'
# read -p 'Press [Enter] to continue...'

$SUDO reboot

