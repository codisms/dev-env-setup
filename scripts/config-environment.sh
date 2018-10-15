
cd ${HOME}
ln -s ./.dotfiles/repos/dircolors-solarized/dircolors.256dark .dircolors
ln -s ./.dotfiles/zshrc .zshrc
ln -s ./.dotfiles/gitconfig .gitconfig
ln -s ./.dotfiles/elinks .elinks
ln -s ./.dotfiles/muttrc .muttrc
ln -s ./.dotfiles/ctags .ctags
ln -s ./.dotfiles/eslintrc .eslintrc
ln -s ./.dotfiles/editorconfig .editorconfig
ln -s ./.dotfiles/psqlrc .psqlrc

if [ -f ./.codisms/pgpass ]; then
	ln -s ./.codisms/pgpass .pgpass

	chmod 600 .pgpass
	chmod 600 .codisms/pgpass
fi

reloadEnvironment
