#echo
#echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#echo Generating SSH key...
##read -p 'Press [Enter] to continue...'

#echo
ssh-keygen -t rsa -N "" -C "$(hostname)" -f ${HOME}/.ssh/id_rsa
