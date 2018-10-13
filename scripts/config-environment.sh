
if [ -d ${HOME}/.codisms ]; then
	ln -s ${HOME}/.codisms/repos/dircolors-solarized/dircolors.256dark ${HOME}/.dircolors
	ln -s ${HOME}/.codisms/zshrc ${HOME}/.zshrc
	ln -s ${HOME}/.codisms/gitconfig ${HOME}/.gitconfig
	ln -s ${HOME}/.codisms/elinks ${HOME}/.elinks
	ln -s ${HOME}/.codisms/muttrc ${HOME}/.muttrc
	ln -s ${HOME}/.codisms/ctags ${HOME}/.ctags
	ln -s ${HOME}/.codisms/pgpass ${HOME}/.pgpass
	ln -s ${HOME}/.codisms/eslintrc ${HOME}/.eslintrc
	ln -s ${HOME}/.codisms/editorconfig ${HOME}/.editorconfig
	ln -s ${HOME}/.codisms/psqlrc ${HOME}/.psqlrc

	chmod 600 ${HOME}/.pgpass
	chmod 600 ${HOME}/.codisms/pgpass
else
	notice "Environment left default"
fi

reloadEnvironment
