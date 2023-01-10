
cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
$SUDO DEBIAN_FRONTEND=noninteractive apt-get -fy install software-properties-common fonts-liberation libappindicator3-1 libatk-bridge2.0-0 libgtk-3-0 libgbm1 libu2f-udev
$SUDO DEBIAN_FRONTEND=noninteractive apt-get -fy install
$SUDO DEBIAN_FRONTEND=noninteractive dpkg -i google-chrome*.deb
