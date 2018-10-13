if [ -f /etc/sudoers ]; then
	echo "Updating /etc/sudoers..."

	echo Looking for user $MY_USER in /etc/sudoers...
	if ! $SUDO grep -q $MY_USER /etc/sudoers; then
		echo "  Adding user to /etc/sudoers..."
		echo "$MY_USER ALL=(ALL:ALL) NOPASSWD: ALL" | $SUDO EDITOR='tee -a' visudo > /dev/null
	else
		echo "  User already exists"
		grep $MY_USER /etc/sudoers
	fi
	#cat /etc/sudoers
fi
