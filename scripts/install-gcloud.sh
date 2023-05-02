curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | $SUDO apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | $SUDO tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
apt_get_update
apt_get_install google-cloud-cli
