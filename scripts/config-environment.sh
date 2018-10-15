
ln -s ${HOME}/.dotfiles/repos/dircolors-solarized/dircolors.256dark ${HOME}/.dircolors
ln -s ${HOME}/.dotfiles/zshrc ${HOME}/.zshrc
ln -s ${HOME}/.dotfiles/gitconfig ${HOME}/.gitconfig
ln -s ${HOME}/.dotfiles/elinks ${HOME}/.elinks
ln -s ${HOME}/.dotfiles/muttrc ${HOME}/.muttrc
ln -s ${HOME}/.dotfiles/ctags ${HOME}/.ctags
ln -s ${HOME}/.dotfiles/eslintrc ${HOME}/.eslintrc
ln -s ${HOME}/.dotfiles/editorconfig ${HOME}/.editorconfig
ln -s ${HOME}/.dotfiles/psqlrc ${HOME}/.psqlrc

if [ -d ${HOME}/.codisms ]; then
	ln -s ${HOME}/.codisms/pgpass ${HOME}/.pgpass

	chmod 600 ${HOME}/.pgpass
	chmod 600 ${HOME}/.codisms/pgpass
fi

reloadEnvironment
