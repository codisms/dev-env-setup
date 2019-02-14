
PRIVATE_REPO=$(option_value private-repo)
debug "PRIVATE_REPO = ${PRIVATE_REPO}"

if [ "$PRIVATE_REPO" != "" ]; then
	echo "Downloading private repo..."

	printSubHeader "Cloning private repo..."
	retry git clone --depth=1 "${PRIVATE_REPO}" ${HOME}/.dotfiles.private
else
	echo "Clone private repo template..."
	retry git clone --depth=1 https://github.com/codisms/env-config-private-template ${HOME}/.dotfiles.private

	cd ${HOME}/.dotfiles.private
	rm -rf .git
	git init
	git add .
	#git commit -m "Initial"
	cd ${HOME}
fi

if [ -f ${HOME}/.dotfiles.private/install.sh ]; then
	printSubHeader "Running install script..."
	${HOME}/.dotfiles.private/install.sh
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

	if [ "$3" != "" ]; then
		chmod $3 ${TARGET}
		chmod $3 ${NAME}
	fi
}

cd ${HOME}

echo -e "\e[35mSetting up symlinks...\e[0m"

createSymlink ./.dotfiles.private/netrc .netrc 600
createSymlink ./.dotfiles.private/aws .aws 600
createSymlink ./.dotfiles.private/pgpass .pgpass 600

echo -e "\e[35mSetting ssh config...\e[0m"

if [ ! -d .ssh ]; then
	mkdir -p .ssh
fi
if [ ! -d .ssh/controlmasters ]; then
	mkdir -p .ssh/controlmasters
fi
chmod -R 700 .ssh
if [ -f ./.dotfiles.private/ssh/authorized_keys ]; then
	cat ./.dotfiles.private/ssh/authorized_keys >> ${HOME}/.ssh/authorized_keys
fi
if [ -f ./.dotfiles.private/ssh/config ]; then
	echo "Include ~/.dotfiles.private/ssh/config" >> ${HOME}/.ssh/config
fi
#chown ${USER}:${USER} *
cd .ssh
chmod 600 *
cd ..

if [ -f ${HOME}/.dotfiles.private/gitconfig ]; then
	echo "[include]" >> ${HOME}/.gitconfig
	echo "	path = ~/.dotfiles.private/gitconfig" >> ${HOME}/.gitconfig
fi

#echo -e "\e[35mDownloading private repo submodules...\e[0m"
#cd ${HOME}/.dotfiles.private
#git submodule update --init --recursive

echo -e "\e[35mFinishing up...\e[0m"

if [ -f ${HOME}/.dotfiles.private/.git/config ]; then
	sed -i s/codisms@// ${HOME}/.dotfiles.private/.git/config
fi

if [ -d ./.dotfiles.private/bin ]; then
	echo "export PATH=\${PATH}:~/.dotfiles.private/bin" >> ~/.profile
fi

resetPermissions
reloadEnvironment
