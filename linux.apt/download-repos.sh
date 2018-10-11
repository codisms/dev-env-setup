printHeader "Downloading repos..." "dl-repos"

printSubHeader "Cloning dev-config..."
echo 'Cloning .codisms; enter bitbucket.org password for "codisms":'
retry git clone https://codisms@bitbucket.org/codisms/dev-config.git ${MY_HOME}/.codisms

printSubHeader "Configuring security..."

ln -s ${MY_HOME}/.codisms/netrc ${MY_HOME}/.netrc
chmod 600 ${MY_HOME}/.netrc

mkdir -p ${MY_HOME}/.ssh
chmod 700 ${MY_HOME}/.ssh
mkdir -p ${MY_HOME}/.ssh/controlmasters
cd ${MY_HOME}/.ssh
[ -f authorized_keys ] && mv authorized_keys authorized_keys.orig
find ../.codisms/ssh/ -type f -exec ln -s {} \;
#chown ${MY_USER}:${MY_USER} *
chmod 600 *

sed -i s/codisms@// ${MY_HOME}/.codisms/.git/config

printSubHeader "Downloading submodules..."

cd ${MY_HOME}/.codisms
retry git submodule update --init --recursive

printSubHeader "Cloning db code..."
retry git clone https://bitbucket.org/codisms/db.git ${MY_HOME}/db

printSubHeader "Resetting permissions..."
resetPermissions
