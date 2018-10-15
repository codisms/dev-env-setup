echo "Setting crontab jobs ${USER} ${HOME}..."
set +e
${HOME}/.dotfiles/config-crontab.sh
set -e
