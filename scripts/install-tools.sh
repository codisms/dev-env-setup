
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

echo "Installing tools...."
installAwsCli
installCertbot

retry pip install pillow imgcat

reloadEnvironment
