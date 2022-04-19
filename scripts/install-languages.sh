echo "Installing languages..."

updatePython() {
	printSubHeader "Configuring python..." "python"
	$SUDO update-alternatives --install /usr/bin/python python /usr/bin/python3 1
	$SUDO update-alternatives --install /usr/bin/python python /usr/bin/python2 2
	$SUDO update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
	$SUDO update-alternatives --set python /usr/bin/python3

	printSubHeader "Setting up pip..." "python"
	if [ ! -d ~/.cache/pip ]; then
		mkdir -p ~/.cache/pip
		chmod 775 ~/.cache/pip
	else
		chmod -R g+rw ~/.cache/pip
		chmod -R o+r ~/.cache/pip
	fi

	# ** Don't do this
	#printSubHeader "Updating pip..."
	#pip install --upgrade pip

	reloadEnvironment
}

installNode() {
	NODE_VERSION=$1
	printSubHeader "Installing Node.js v${NODE_VERSION}..."
	curl -o- -sSL https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
	echo 'export NVM_DIR="$HOME/.nvm"' >> ${HOME}/.profile
	echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ${HOME}/.profile
	reloadEnvironment
	nvm install ${NODE_VERSION}

	printSubHeader "Installing tools..."
	npm install --quiet -g npm > /dev/null
	npm install --quiet -g nodemon ionic eslint typescript tslint json http-server pm2
	#	grunt-cli gulp-cli webpack bower jshint \
	# Angular 8+ prompts if CI is not "true"
	CI=true npm install --quier -g @angular/cli

	#curl -o- -sSL https://deb.nodesource.com/setup_8.x | sudo -E bash -
	#apt_get_install nodejs build-essential

	##echo "Updating npm..."
	##npm install --quiet --loglevel warn -g npm > /dev/null

	## workarounds...
	##mkdir -p ~/.node-gyp/8.9.1
	##mkdir -p /usr/lib/node_modules/@angular/cli/node_modules/node-sass/vendor

	#printSubHeader "Installing tools..."
	#$SUDO npm install --quiet --loglevel warn -g grunt-cli gulp-cli nodemon bower json http-server nodemon jshint eslint typescript > /dev/null
	#$SUDO npm install --quiet --unsafe-perm --loglevel warn -g @angular/cli > /dev/null
	#$SUDO npm install --quiet --loglevel warn -g ionic > /dev/null

	reloadEnvironment
}

installRuby() {
	RUBY_VERSION=$1
	printSubHeader "Installing Ruby v${RUBY_VERSION}..."
	apt_get_install software-properties-common
	#apt_add_repository ppa:rael-gc/rvm
	#apt_get_update
	#apt_get_install rvm
	#source /etc/profile.d/rvm.sh

	if [ -d ~/.rvm ]; then
		echo "Removing existing rvm installation"
		rm -rf ~/.rvm
	fi

	printSubHeader "Downloading GPG keys..."
	retry gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	curl -o- -sSL https://get.rvm.io | bash -s stable
	reloadEnvironment
	source ${HOME}/.rvm/scripts/rvm

	printSubHeader "Downloading and installing Ruby..."
	retry rvm install ruby-${RUBY_VERSION}
	#source /etc/profile.d/rvm.sh
	#source ${HOME}/.rvm/scripts/rvm
	reloadEnvironment

	printSubHeader "Running bundler..."
	retry gem install bundler

	reloadEnvironment
}

installGo() {
	GO_VERSION=$1
	GO_VERSION=$(curl https://go.dev/dl/ | grep -oE '/dl/go[0-9]\.[0-9]+(\.[0-9]+)?.linux-amd64.tar.gz' | grep -oE '[0-9]\.[0-9]+(\.[0-9]+)' | head -n 1)
	printSubHeader "Installing Go v${GO_VERSION}..."

	url=https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
	aria2c --max-connection-per-server=4 --dir=/tmp --out=go.tar.gz "${url}"
	$SUDO tar -C /usr/local -xzf /tmp/go.tar.gz
	#export PATH=${PATH}:/usr/local/go/bin
	#export GOPATH=${HOME}/go
	echo "export PATH=\${PATH}:/usr/local/go/bin:~/go/bin" >> ~/.profile
	#apt_get_install golang-1.14
	#echo "export PATH=\${PATH}:/usr/lib/go-1.14/bin:~/go/bin" >> ~/.profile
	echo "export GOPATH=${HOME}/go" >> ~/.profile
	reloadEnvironment

	printSubHeader "Setting up Go directory structure..."
	mkdir -p ${HOME}/go/bin
	mkdir -p ${HOME}/go/pkg
	mkdir -p ${HOME}/go/src/github.com

	cd ${HOME}/go

	printSubHeader "Downloading goimports..."
	GOPATH=`pwd` go install golang.org/x/tools/cmd/goimports@latest

	printSubHeader "Downloading go tools..."
	GOPATH=`pwd` go install golang.org/x/tools/...@latest

	printSubHeader "Downloading go-watcher..."
	#GOPATH=`pwd` go install github.com/canthefason/go-watcher@latest
	GOPATH=`pwd` go install github.com/canthefason/go-watcher/cmd/watcher@latest

	cd ${SCRIPT_FOLDER}

	reloadEnvironment
}

ssh-keyscan -H github.com >> ~/.ssh/known_hosts

updatePython
installNode 12
installRuby 2.7
installGo 1.18

