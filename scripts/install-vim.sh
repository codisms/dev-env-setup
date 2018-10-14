printSubHeader "Installing vim..."
PATH="${PATH}" curl -sSL -H 'Cache-Control: no-cache' https://github.com/codisms/vim-config/raw/master/install.sh | bash -s -- --build

