printSubHeader "Installing env-config..."
curl -sSL -H 'Cache-Control: no-cache' https://github.com/codisms/tmux-config/raw/master/install.sh | bash -s

reloadEnvironment
