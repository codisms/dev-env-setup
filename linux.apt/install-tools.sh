
installCertbot() {
	printSubHeader "Installing certbot"
	apt_add_repository ppa:certbot/certbot
	apt_get_update
	apt_get_install python-certbot-apache python-certbot-nginx
}

installAwsCli() {
	printSubHeader "Installing aws-cli"
	retry pip install awscli --upgrade --user
}

printHeader "Installing tools....", "tools"
installAwsCli
installCertbot
