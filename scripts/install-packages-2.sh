
postInstall() {
	$SUDO chmod 755 ${HOME}
	[ -d ${HOME}/web ] && chown -R apache:apache ${HOME}/web

	printSubHeader "Configuring apache modules"
	$SUDO a2enmod proxy proxy_http proxy_wstunnel rewrite auth_basic proxy_balancer proxy_html proxy_connect ssl xml2enc substitute

	startServices
}

installChrome() {
	printSubHeader "Installing Chrome..."
	PATH="${PATH}" ${HOME}/.codisms/bin/install-chrome
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

	ln -s ${HOME}/.codisms/psqlrc ${HOME}/.psqlrc
}

installVim() {
	printSubHeader "Installing vim..."
	PATH="${PATH}" ${HOME}/.codisms/bin/install-vim --pwd=${HOME} --build
}

installTmux() {
	printSubHeader "Installing libevent 2.x..."
	apt_get_install libevent-2* libevent-dev

	printSubHeader "Installing tmux..."
	PATH="${PATH}" ${HOME}/.codisms/bin/install-tmux --version=2.6 --pwd=${HOME} --build
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

echo "Installing packages..."
installPostgres
installVim
installTmux
installChrome

reloadEnvironment

postInstall