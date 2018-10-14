printSubHeader "Installing libevent 2.x..."
apt_get_install libevent-2* libevent-dev

printSubHeader "Installing tmux..."
curl -sSL -H 'Cache-Control: no-cache' https://github.com/codisms/tmux-config/raw/master/install.sh | bash -s --build --version=2.6
