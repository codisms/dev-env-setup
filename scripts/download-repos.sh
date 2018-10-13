echo "Downloading repos..."

printSubHeader "Cloning dev-config..."
echo 'Cloning .codisms; enter bitbucket.org password for "codisms":'
retry git clone --depth=1 https://codisms@bitbucket.org/codisms/dev-config.git ${HOME}/.codisms

printSubHeader "Configuring security..."

ln -s ${HOME}/.codisms/netrc ${HOME}/.netrc
chmod 600 ${HOME}/.netrc

mkdir -p ${HOME}/.ssh
chmod 700 ${HOME}/.ssh
mkdir -p ${HOME}/.ssh/controlmasters
cd ${HOME}/.ssh
[ -f authorized_keys ] && mv authorized_keys authorized_keys.orig
find ../.codisms/ssh/ -type f -exec ln -s {} \;
#chown ${USER}:${USER} *
chmod 600 *

sed -i s/codisms@// ${HOME}/.codisms/.git/config

printSubHeader "Downloading submodules..."

cd ${HOME}/.codisms
retry git submodule update --init --recursive

printSubHeader "Cloning db code..."
retry git clone --depth=1 https://bitbucket.org/codisms/db.git ${HOME}/db

cd "$SCRIPT_FOLDER"

resetPermissions
