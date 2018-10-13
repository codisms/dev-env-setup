if [ "$NEW_HOST_NAME" != "" ]; then
	#echo SUDO=$SUDO
	echo Setting host name to "${NEW_HOST_NAME}"...

	$SUDO sh -c "echo nameserver 8.8.8.8 >>/etc/resolv.conf; \
		echo nameserver 8.8.4.4 >>/etc/resolv.conf; \
		echo 127.0.0.1 ${NEW_HOST_NAME}>> /etc/hosts"

	$SUDO hostnamectl set-hostname ${NEW_HOST_NAME}
fi
