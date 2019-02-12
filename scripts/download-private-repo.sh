
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
	echo "Clone private repo template..."
	retry git clone --depth=1 https://github.com/codisms/env-config-private-template ${HOME}/.dotfiles.private
	rm -rf ${HOME}/.dotfiles.private/.git
fi

function createSymlink() {
	local TARGET=$1
	local NAME=$2

	if [ -L ${NAME} ]; then
		rm ${NAME}
	fi
	if [ -f ${NAME} ]; then
		mv ${NAME} ${NAME}.disabled
	fi
	ln -s ${TARGET} ${NAME}
}

cd ${HOME}

echo -e "\e[35mSetting up symlinks...\e[0m"

if [ -f ./.dotfiles.private/netrc ]; then
	createSymlink ./.dotfiles.private/netrc .netrc
	chmod 600 .netrc
fi

if [ -f ./.dotfiles.private/aws ]; then
	createSymlink ./.dotfiles.private/aws .aws
	chmod 600 .aws
fi

if [ -f ./.dotfiles.private/pgpass ]; then
	createSymlink ./.dotfiles.private/pgpass .pgpass

	chmod 600 .pgpass
	chmod 600 .dotfiles.private/pgpass
fi

echo -e "\e[35mSetting ssh config...\e[0m"

if [ ! -d .ssh ]; then
	mkdir -p .ssh
fi
if [ ! -d .ssh/controlmasters ]; then
	mkdir -p .ssh/controlmasters
fi
chmod -R 700 .ssh
cd .ssh
if [ -f authorized_keys ] && [ ! -f authorized_keys.orig ]; then
	mv authorized_keys authorized_keys.orig
fi
find ../.dotfiles.private/ssh/ -type f -exec ln -s {} \;
#chown ${USER}:${USER} *
chmod 600 *

echo -e "\e[35mDownloading private repo submodules...\e[0m"
cd ${HOME}/.dotfiles.private
git submodule update --init --recursive

echo -e "\e[35mFinishing up...\e[0m"

sed -i s/codisms@// ${HOME}/.dotfiles.private/.git/config

echo "export PATH=\${PATH}:~/.dotfiles.private/bin" >> ~/.profile


resetPermissions
reloadEnvironment
