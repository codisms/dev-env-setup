echo "Installing apt-fast..."

apt_add_repository ppa:apt-fast/stable
apt_get_update
apt_get_install apt-fast
#mkdir -p ${MY_HOME}/.config/aria2/
#echo "log-level=warn" >> ~/.config/aria2/input.conf
sudo sed -i 's|--no-conf |--no-conf --console-log-level=warn |' /etc/apt-fast.conf

reloadEnvironment
