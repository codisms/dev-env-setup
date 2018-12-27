
cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
$SUDO apt-get -fy install software-properties-common fonts-liberation libappindicator3-1 libatk-bridge2.0-0 libgtk-3-0
$SUDO apt-get -fy install
$SUDO dpkg -i google-chrome*.deb
