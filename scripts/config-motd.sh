echo "Setting motd..."
[ -f /etc/motd ] && $SUDO mv /etc/motd /etc/motd.orig
figlet -d ${HOME}/.setup/ -f "ANSI Shadow" "$(hostname)" -w 150 > /tmp/motd
$SUDO mv /tmp/motd /etc/motd
