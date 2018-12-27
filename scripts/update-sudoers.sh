if [ -f /etc/sudoers ]; then
	echo "Updating /etc/sudoers..."

	echo Looking for user $USER in /etc/sudoers...
	if ! $SUDO grep -q $USER /etc/sudoers; then
		echo "  Adding user to /etc/sudoers..."
		echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | $SUDO EDITOR='tee -a' visudo > /dev/null
	else
		echo "  User already exists"
		$SUDO grep $USER /etc/sudoers
	fi
	#cat /etc/sudoers
fi
