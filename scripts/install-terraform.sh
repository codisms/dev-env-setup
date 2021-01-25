curl -fsSL https://apt.releases.hashicorp.com/gpg | $SUDO apt-key add -
apt_add_repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt_get_update
apt_get_install terraform
