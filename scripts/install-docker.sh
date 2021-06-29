apt_get_install ca-certificates software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO apt-key add -

apt_add_repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) stable"

apt_get_update
apt_get_install docker-ce docker-compose

${SUDO} usermod -aG docker ${USER}
