	cat <<EOF >> ${HOME}/.onstart.message

[35mInstalled versions:[0m

OS: $(lsb_release --description --short)
Kernel: $(uname -a)

PostgreSQL: $(psql --version)
Redis: $(redis-server --version)
Docker: $(docker --version)

Go: $(go version)
Node: $(node --version)
Python: $(python --version)
Ruby: $(ruby --version)

vim: $(vim --version | head -n 1)
tmux: $(tmux -V)
Git: $(git --version)

EOF
fi
