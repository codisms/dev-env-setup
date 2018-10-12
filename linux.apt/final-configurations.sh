echo "Making final configuration changes..."
printSubHeader "Setting motd..."
[ -f /etc/motd ] && $SUDO mv /etc/motd /etc/motd.orig
$SUDO ln -s ${MY_HOME}/.codisms/motd /etc/motd

printSubHeader "Setting zsh as default shell..."
[ -f /etc/ptmp ] && $SUDO rm -f /etc/ptmp
$SUDO chsh -s `which zsh` ${MY_USER}

printSubHeader "Setting crontab jobs ${MY_USER} ${MY_HOME}..."
set +e
(crontab -u ${MY_USER} -l 2>/dev/null; \
	echo "0 5 * * * ${MY_HOME}/.codisms/bin/crontab-daily"; \
	echo "5 5 * * 1 ${MY_HOME}/.codisms/bin/crontab-weekly"; \
	echo "15 5 1 * * ${MY_HOME}/.codisms/bin/crontab-monthly") | crontab -u ${MY_USER} -
set -e
