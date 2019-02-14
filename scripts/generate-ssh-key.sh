if [ ! -f ${HOME}/.ssh/id_rsa ]; then
	#echo
	#echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	#echo Generating SSH key...
	##read -p 'Press [Enter] to continue...'

	#echo
	ssh-keygen -t rsa -N "" -C "$(hostname)" -f ${HOME}/.ssh/id_rsa

	cat <<EOF >> ${HOME}/.onstart.message

Please make sure to use the following public SSH key wherever needed:

$(cat ${HOME}/.ssh/id_rsa.pub)

EOF
fi
