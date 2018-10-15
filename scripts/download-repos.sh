SKIP_REPO=$(option_set skip-repo)
debug "SKIP_REPO = ${SKIP_REPO}"

if [ $SKIP_REPO -eq 1 ]; then
	notice "Skipping repo download!"
else
	echo "Downloading dev-config..."

	REPO_PASSWORD=$(option_value repo-password)

	printSubHeader "Cloning dev-config..."
	echo 'Cloning .codisms; enter bitbucket.org password for "codisms":'
	retry git clone --depth=1 "https://codisms:${REPO_PASSWORD}@bitbucket.org/codisms/dev-config.git" ${HOME}/.codisms

	printSubHeader "Configuring security..."

	cd ${HOME}
	ln -s ./.codisms/netrc /.netrc
	chmod 600 /.netrc

	if [ -d .ssh ]; then
		mkdir -p .ssh
	fi
	if [ -D .ssh/controlmasters ]; then
		mkdir -p .ssh/controlmasters
	fi
	chmod -R 700 .ssh
	cd .ssh
	[ -f authorized_keys ] && mv authorized_keys authorized_keys.orig
	find ../.codisms/ssh/ -type f -exec ln -s {} \;
	#chown ${USER}:${USER} *
	chmod 600 *

	sed -i s/codisms@// ${HOME}/.codisms/.git/config

	printSubHeader "Downloading dev-config submodules..."
	cd ${HOME}/.codisms
	retry git submodule update --init --recursive

	printSubHeader "Cloning db code..."
	retry git clone --depth=1 https://bitbucket.org/codisms/db.git ${HOME}/db
fi

echo "Downloading env-config..."

printSubHeader "Cloning env-config..."
retry git clone --depth=1 "https://github.com/codisms/env-config.git" ${HOME}/.dotfiles

printSubHeader "Downloading env-config submodules..."
cd ${HOME}/.dotfiles
retry git submodule update --init --recursive

cd "$SCRIPT_FOLDER"

resetPermissions
