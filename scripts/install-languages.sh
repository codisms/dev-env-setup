echo "Installing languages..."

updatePip() {
	printSubHeader "Setting up pip..." "pip"
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
	printSubHeader "Installing Node.js..."
	curl -o- -sSL https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
	echo 'export NVM_DIR="$HOME/.nvm"' >> ${HOME}/.profile
	echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ${HOME}/.profile
	reloadEnvironment
	nvm install node

	printSubHeader "Installing tools..."
	npm install --quiet -g npm > /dev/null
	npm install --quiet -g nodemon \
		grunt-cli gulp-cli webpack ionic bower webpack-bundle-analyzer \
		jshint eslint typescript tslint \
		json http-server pm2
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
	printSubHeader "Installing Ruby..."
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
	retry gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	curl -o- -sSL https://get.rvm.io | bash -s stable
	reloadEnvironment
	source ${HOME}/.rvm/scripts/rvm

	printSubHeader "Downloading and installying Ruby..."
	retry rvm install ruby-2.3
	#source /etc/profile.d/rvm.sh
	#source ${HOME}/.rvm/scripts/rvm
	reloadEnvironment

	printSubHeader "Running bundler..."
	retry gem install bundler

	reloadEnvironment
}

installGo() {
	printSubHeader "Setting up Go..."

	GOURLREGEX='https://dl.google.com/go/go[0-9\.]+\.linux-amd64.tar.gz'
	echo "Finding latest version of Go for AMD64..."
	url="$(wget -qO- https://golang.org/dl/ | grep -oP 'https:\/\/dl\.google\.com\/go\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1 )"
	latest="$(echo $url | /bin/grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )"
	echo "Downloading latest Go for AMD64: ${latest}"
	aria2c --max-connection-per-server=4 --dir=/tmp --out=go.tar.gz "${url}"
	$SUDO tar -C /usr/local -xzf /tmp/go.tar.gz
	#export PATH=${PATH}:/usr/local/go/bin
	#export GOPATH=${HOME}/go
	echo "export PATH=\${PATH}:/usr/local/go/bin:~/go/bin" >> ~/.profile
	echo "export GOPATH=${HOME}/go" >> ~/.profile
	reloadEnvironment

	printSubHeader "Setting up Go directory structure..."
	mkdir -p ${HOME}/go/bin
	mkdir -p ${HOME}/go/pkg
	mkdir -p ${HOME}/go/src/github.com

	cd ${HOME}/go

	printSubHeader "Downloading goimports..."
	GOPATH=`pwd` go get golang.org/x/tools/cmd/goimports

	printSubHeader "Downloading go tools..."
	GOPATH=`pwd` go get -u golang.org/x/tools/...

	printSubHeader "Downloading go-watcher..."
	GOPATH=`pwd` go get github.com/canthefason/go-watcher
	GOPATH=`pwd` go install github.com/canthefason/go-watcher/cmd/watcher

	cd ${SCRIPT_FOLDER}

	reloadEnvironment
}

installNode
installRuby
installGo
updatePip
echo '~~~'

