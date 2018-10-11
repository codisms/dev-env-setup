printHeader "Removing unused packages...", "autoremove"
$SUDO service apache2 stop
apt_get_autoremove
