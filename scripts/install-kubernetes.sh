curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | $SUDO apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | $SUDO tee -a /etc/apt/sources.list.d/kubernetes.list
apt_get_update
apt_get_install kubectl
