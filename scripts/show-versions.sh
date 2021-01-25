	cat <<EOF >> ${HOME}/.onstart.message

[35mInstalled versions:[0m

 [36mOS:         [0m  $(lsb_release --description --short)
 [36mKernel:     [0m  $(uname -a)

 [36mPostgreSQL: [0m  $(psql --version)
 [36mRedis:      [0m  $(redis-server --version)
 [36mDocker:     [0m  $(docker --version)

 [36mGo:         [0m  $(go version)
 [36mNode:       [0m  $(node --version)
 [36mPython:     [0m  $(python --version)
 [36mRuby:       [0m  $(ruby --version)

 [36mvim:        [0m  $(vim --version | head -n 1)
 [36mtmux:       [0m  $(tmux -V)
 [36mGit:        [0m  $(git --version)

EOF
