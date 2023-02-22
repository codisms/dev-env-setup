
installCertbot() {
	printSubHeader "Installing certbot"
	#apt_add_repository ppa:certbot/certbot
	#apt_get_update
	#apt_get_install python-certbot-apache
	#apt_get_install python-certbot-nginx
	curl -o- https://raw.githubusercontent.com/vinyll/certbot-install/master/install.sh | bash
}

installAwsCli() {
	printSubHeader "Installing aws-cli"
	retry pip install awscli --upgrade --user
}

installDBMate() {
	printSubHeader "Installing dbmate"
	$SUDO curl -fsSL -o /usr/local/bin/dbmate https://github.com/amacneil/dbmate/releases/latest/download/dbmate-linux-amd64
	$SUDO chmod +x /usr/local/bin/dbmate
}

echo "Installing tools...."
installAwsCli
installCertbot
installDBMate

retry pip install pillow imgcat

reloadEnvironment
