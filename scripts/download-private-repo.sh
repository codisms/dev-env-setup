PRIVATE_REPO=$(option_value private-repo)
debug "PRIVATE_REPO = ${PRIVATE_REPO}"

if [ "$PRIVATE_REPO" != "" ]; then
	echo "Downloading private repo..."

	printSubHeader "Cloning private repo..."
	retry git clone --depth=1 "${PRIVATE_REPO}" ${HOME}/.dotfiles.private

	if [ -f ${HOME}/.dotfiles.private/install.sh ]; then
		printSubHeader "Running install script..."
		${HOME}/.dotfiles.private/install.sh
	fi
else
	echo "Skipping private repo download"
fi

resetPermissions
reloadEnvironment
