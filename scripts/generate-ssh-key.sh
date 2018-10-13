if [ ! -f ${HOME}/.ssh/id_rsa ]; then

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Generating SSH key...
	##read -p 'Press [Enter] to continue...'

	echo
	ssh-keygen -t rsa -N "" -f ${HOME}/.ssh/id_rsa
fi
