echo "Setting motd..."
[ -f /etc/motd ] && $SUDO mv /etc/motd /etc/motd.orig
echo $(hostname) | figlet -d ${HOME}/.setup/ -f "ANSI Shadow" > /tmp/motd
$SUDO mv /tmp/motd /etc/motd
