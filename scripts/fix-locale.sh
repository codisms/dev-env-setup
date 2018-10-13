if [ "$LC_CTYPE" == "" ] || [ "$LC_ALL" == "" ]; then
	echo "Fixing locales..."

	#export LC_ALL="en_US.UTF-8"
	#export LC_CTYPE="en_US.UTF-8"
	#retry_long $SUDO dpkg-reconfigure locales
	apt_get_install locales language-pack-en
fi
