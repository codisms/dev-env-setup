apt_get_install apt-transport-https ca-certificates curl gnupg2 software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO apt-key add -

$SUDO add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) stable"

$SUDO apt-get update
$SUDO apt-get install docker-ce

