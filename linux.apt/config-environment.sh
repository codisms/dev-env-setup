
printHeader "Configuring environment..." "config-env"

ln -s ${MY_HOME}/.codisms/repos/dircolors-solarized/dircolors.256dark ${MY_HOME}/.dircolors
ln -s ${MY_HOME}/.codisms/zshrc ${MY_HOME}/.zshrc
ln -s ${MY_HOME}/.codisms/gitconfig ${MY_HOME}/.gitconfig
ln -s ${MY_HOME}/.codisms/elinks ${MY_HOME}/.elinks
ln -s ${MY_HOME}/.codisms/muttrc ${MY_HOME}/.muttrc
ln -s ${MY_HOME}/.codisms/ctags ${MY_HOME}/.ctags
ln -s ${MY_HOME}/.codisms/pgpass ${MY_HOME}/.pgpass
ln -s ${MY_HOME}/.codisms/eslintrc ${MY_HOME}/.eslintrc
ln -s ${MY_HOME}/.codisms/editorconfig ${MY_HOME}/.editorconfig
chmod 600 ${MY_HOME}/.pgpass
chmod 600 ${MY_HOME}/.codisms/pgpass

