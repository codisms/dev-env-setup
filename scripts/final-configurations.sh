echo "Making final configuration changes..."

if hash ufw 2>/dev/null; then
	echo Disabling firewalld...
	$SUDO ufw disable
fi

if [ -f ${HOME}/.codisms/vimrc.dbext ]; then
	cd ${HOME}/.vim
	if [ -L vimrc.dbext ]; then
		rm vimrc.dbext
	fi
	ln -s ../.codisms/vimrc.dbext
fi

printSubHeader "Setting motd..."
[ -f /etc/motd ] && $SUDO mv /etc/motd /etc/motd.orig
$SUDO ln -s ${HOME}/.dotfiles/motd /etc/motd

printSubHeader "Setting crontab jobs ${USER} ${HOME}..."
set +e
(crontab -u ${USER} -l 2>/dev/null; \
	echo "0 5 * * * ${HOME}/.dotfiles/bin/crontab-daily"; \
	echo "5 5 * * 1 ${HOME}/.dotfiles/bin/crontab-weekly"; \
	echo "15 5 1 * * ${HOME}/.dotfiles/bin/crontab-monthly") | crontab -u ${USER} -
set -e

printSubHeader "Setting zsh as default shell..."
[ -f /etc/ptmp ] && $SUDO rm -f /etc/ptmp
$SUDO chsh -s `which zsh` ${USER}
