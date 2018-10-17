printSubHeader "Installing env-config..."
curl -sSL https://github.com/codisms/env-config/raw/master/install.sh | bash -s

reloadEnvironment
