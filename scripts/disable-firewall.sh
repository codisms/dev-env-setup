if hash ufw 2>/dev/null; then
	echo Disabling firewalld...
	$SUDO ufw disable
fi
