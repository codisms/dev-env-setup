
echo "Checking memory requirements"

# https://unix.stackexchange.com/a/233287
#FREE_MEMORY=$(free | awk -v RS="" '{ print $10 / 1024; }' | bc)
MAIN_MEMORY=$(cat /proc/meminfo | grep -e 'MemFree' | awk -v RS="" '{ print $2; }')
SWAP_MEMORY=$(cat /proc/meminfo | grep -e 'SwapFree' | awk -v RS="" '{ print $2; }')
FREE_MEMORY=$(($SWAP_MEMORY + $MAIN_MEMORY))

SWAP_NEEDED=0
echo MAIN_MEMORY = ${MAIN_MEMORY}
echo SWAP_MEMORY = ${SWAP_MEMORY}
echo FREE_MEMORY = ${FREE_MEMORY}
if [ $FREE_MEMORY -lt 4194304 ]; then
	echo -e "\e[31;5mLow memory detected; expanding swap...\e[0m"
	SWAP_NEEDED=1
else
	if [ $SWAP_MEMORY -eq 0 ]; then
		echo -e "\e[31;5mNo swap detected; creating swap file...\e[0m"
		SWAP_NEEDED=1
	fi
fi

if [ $SWAP_NEEDED -eq 1 ]; then
	# https://serverfault.com/questions/218750/why-dont-ec2-ubuntu-images-have-swap/279632#279632
	# https://www.computerhope.com/unix/swapon.htm
	$SUDO dd if=/dev/zero of=/var/swapfile bs=1M count=4196
	$SUDO chmod 600 /var/swapfile
	$SUDO mkswap /var/swapfile
	$SUDO cp /etc/fstab /etc/fstab.bak
	echo /var/swapfile none swap defaults 0 0 | $SUDO tee -a /etc/fstab > /dev/null
	$SUDO swapon -a
fi

