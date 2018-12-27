
cd /tmp
echo "*1"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
echo "*2"
$SUDO apt-get -fy install software-properties-common fonts-liberation libappindicator3-1 libatk-bridge2.0-0 libgtk-3-0
echo "*3"
$SUDO apt-get -fy install
echo "*4"
$SUDO dpkg -i google-chrome*.deb
echo "*5"
