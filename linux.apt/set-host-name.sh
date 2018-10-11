printHeader "Setting host name..." "hostname"

echo SUDO=$SUDO
echo Setting host name to "$1"...

$SUDO sh -c "echo nameserver 8.8.8.8 >>/etc/resolv.conf; \
	echo nameserver 8.8.4.4 >>/etc/resolv.conf; \
	echo 127.0.0.1 $1>> /etc/hosts"

$SUDO hostnamectl set-hostname $1
