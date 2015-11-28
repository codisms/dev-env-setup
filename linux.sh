#!/bin/bash

set -e

# for new 6.6 install in parallels...
# > vi /boot/grub/grub.conf
# Add " vga=0x333"
# > mkdir ~/.ssh
# > chmod 700 ~/.ssh
# > vi ~/.ssh/authorized_keys
# Add public key
# > restorecon -r -vv /root/.ssh
# > vi /etc/ssh/sshd_config
# Uncomment "PubkeyAuthentication yes"
# Set "PasswordAuthentication" to "no"
# > yum -y update
# > reboot


# Jump to "BEGIN"...

#-----------------------------------------------------------------------------------------------------------
# Configuration

configureSecurity() {
	ln -s ~/.codisms/netrc .netrc
	chmod 600 ~/.netrc

	[ ! -d ~/.ssh ] && mkdir ~/.ssh
	chmod 700 ~/.ssh
	cd ~/.ssh
	find ../.codisms/ssh/ -type f -exec ln -s {} \;
	chmod 600 *
	cd ~
}

configureEnvironment() {
# 	[ ! -d ~/.codisms/repos ] && ~/.codisms/repos
#
# 	cd ~/.codisms/repos

# 	echo Cloning antigen... && git clone --quiet https://github.com/zsh-users/antigen.git
# 	echo Cloning dircolors-solarized... && git clone --quiet https://github.com/seebi/dircolors-solarized.git
# 	echo Cloning solarized... && git clone --quiet https://github.com/altercation/solarized.git

	ln -s ~/.codisms/repos/dircolors-solarized/dircolors.ansi-dark ~/.dircolors
	ln -s ~/.codisms/zshrc ~/.zshrc
	ln -s ~/.codisms/gitconfig ~/.gitconfig
	ln -s ~/.codisms/elinks ~/.elinks
	ln -s ~/.codisms/ctags ~/.ctags

	#echo motd?

	echo Installing zsh...
	yum -y -q install zsh

	chsh -s `which zsh`
}

setHostName() {
	echo Setting host name to "$1"...
	[ -f  /etc/sysconfig/network ] && mv -f /etc/sysconfig/network /etc/sysconfig/network.orig

	cat << EOF > /etc/sysconfig/network
echo NETWORKING=yes
echo HOSTNAME=$1
EOF

	echo 127.0.0.1 $1>> /etc/hosts
}

#-----------------------------------------------------------------------------------------------------------
# Installations

postInstall() {
#	chown -R apache:apache /root/web
	chmod 755 /root

	startServices
}

installPackages() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing packages...
	##read -p 'Press [Enter] to continue...'

	rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
	#yum install -y https://centos6.iuscommunity.org/ius-release.rpm
	echo Updating system...
	yum -y -q update
	echo Installing new modules...
	yum install -y -q git mercurial bzr \
		gcc gcc-c++ kernel-devel \
		automake cmake make libtool \
		ncurses-devel tcl-devel \
		curlpp libcurl-devel clang ctags wget \
		python python-devel \
		perl perl-devel perl-ExtUtils-ParseXS perl-ExtUtils-CBuilder perl-ExtUtils-Embed \
		bind-utils mutt elinks telnet \
		man zsh \
		mysql mysql-server \
		httpd mod_ssl \
		php php-mysql \
		perl-DBD-ODBC freetds \
		openssh-clients openconnect
		#postgresql94-odbc postgresql-odbc postgresql-devel postgresql94-devel
		#tmux nodejs
		#ruby ruby-devel rubygems
		#lua lua-devel luajit luajit-devel
		#python3 python3-devel \

	installNode
	installRuby
	installGo
	installPostgres
	installVim
	installTmux

	postInstall
}

installNode() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing node...
	##read -p 'Press [Enter] to continue...'

	curl -sL https://rpm.nodesource.com/setup | bash -
	#curl -sL https://rpm.nodesource.com/setup_4.x | bash -
	#curl -sL https://rpm.nodesource.com/setup_5.x | bash -
	yum install -q -y nodejs
	npm install --quiet -g npm
	npm install --quiet -g grunt-cli gulp-cli nodemon bower json http-server
}

installPostgres() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing postgresql...
	##read -p 'Press [Enter] to continue...'

	yum install -y -q http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm
	yum install -y -q postgresql94-odbc postgresql94-devel postgresql94 postgresql94-contrib postgresql94-server
	service postgresql-9.4 initdb
	service postgresql-9.4 start
	chkconfig postgresql-9.4 on

	ln -s ~/.codisms/psqlrc ~/.psqlrc
}

installRuby() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing ruby...
	##read -p 'Press [Enter] to continue...'

	#rm -rf ~/.gnupg/
	#gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
	curl -#LO https://rvm.io/mpapis.asc && gpg --import mpapis.asc
	[ -f mpapis.asc ] && rm -f mpapis.asc
	curl -sSL https://get.rvm.io | bash -s stable --rails

	source /usr/local/rvm/scripts/rvm
	source /etc/profile

	#cd ~
	#curl http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz -o ruby-2.2.2.tar.gz
	#tar xzf ruby-2.2.2.tar.gz
	#cd ruby-2.2.2/
	#./configure --disable-dtrace && make && make install
	#cd ..
	#rm -rf ruby-2.2.2
}

installVim() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing vim...
	##read -p 'Press [Enter] to continue...'

	cd ~

	echo Cloning vim...
	git clone --quiet https://github.com/vim/vim.git
	cd vim
	./configure --with-features=huge \
				--enable-multibyte \
				--enable-rubyinterp \
				--enable-pythoninterp \
				--with-python-config-dir=/usr/lib/python2.6/config \
				--enable-perlinterp \
				--enable-luainterp \
				--enable-gui=gtk2 --enable-cscope --prefix=/usr --quiet > /dev/null
	make --quiet VIMRUNTIMEDIR=/usr/share/vim/vim74
	make install --quiet
	cd ..
	rm -rf vim

	ln -s ~/.codisms/vim/vimrc ~/.vimrc
	ln -s ~/.codisms/vim ~/.vim

	echo Removing existing version of vi/vim...
	yum -y -q remove vim-common vim-enhanced vim-minimal

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Setting vim as default...
	##read -p 'Press [Enter] to continue...'

	update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
	update-alternatives --set editor /usr/bin/vim
	update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
	update-alternatives --set vi /usr/bin/vim

	installVimExtensions
}

installVimExtensions_YCM() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing ycm...
	##read -p 'Press [Enter] to continue...'

# 	echo Cloning YouCompleteMe... && git clone --quiet https://github.com/Valloric/YouCompleteMe.git
# 	cd YouCompleteMe
# 	git submodule --quiet update --init --recursive
	#./install.sh --clang-completer
	./install.sh --clang-completer --system-libclang --gocode-completer > /dev/null

	#mkdir ycm_build
	#cd ycm_build
	#cmake -G "Unix Makefiles" -DUSE_SYSTEM_LIBCLANG=ON . ../third_party/ycmd/cpp
	##-DPATH_TO_LLVM_ROOT=~/ycm_temp/llvm_root_dir
	#make ycm_support_libs

	ln -s ~/.codisms/repos/YouCompleteMe ~/.vim/bundle/YouCompleteMe
}

installVimExtensions() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing vim extensions...
	##read -p 'Press [Enter] to continue...'

# 	[ -d ~/.codisms/repos ] && rm -rf ~/.codisms/repos
	[ -d ~/.vim/autoload ] && rm -rf ~/.vim/autoload
	[ -d ~/.vim/bitmaps ] && rm -rf ~/.vim/bitmaps
	[ -d ~/.vim/bundle ] && rm -rf ~/.vim/bundle
	[ -d ~/.vim/colors ] && rm -rf ~/.vim/colors

# 	[ ! -d ~/.codisms/repos ] && mkdir ~/.codisms/repos
#
# 	cd ~/.codisms/repos
#
# 	echo Cloning vim-pathogen... && git clone --quiet https://github.com/tpope/vim-pathogen.git
# 	echo Cloning vim-colors-solarized... && git clone --quiet git://github.com/altercation/vim-colors-solarized.git
# 	#echo Cloning tslime.vim... && git clone --quiet https://github.com/jgdavey/tslime.vim.git
# 	echo Cloning pgsql.vim... && git clone --quiet https://github.com/exu/pgsql.vim.git
# 	#echo Cloning vim-neatstatus... && git clone --quiet git://github.com/maciakl/vim-neatstatus.git
# 	echo Cloning dbext.vim... && git clone --quiet https://github.com/vim-scripts/dbext.vim.git
# 	echo Cloning taboo.vim... && git clone --quiet https://github.com/gcmt/taboo.vim.git
# 	echo Cloning vim-go... && git clone --quiet https://github.com/fatih/vim-go.git
# 	echo Cloning vim-ruby... && git clone --quiet git://github.com/vim-ruby/vim-ruby.git

	[ ! -d ~/.vim/autoload ] && mkdir ~/.vim/autoload
	[ -d ~/.vim/autoload/pathogen ] && rm -rf ~/.vim/autoload/pathogen
	ln -s ~/.codisms/repos/vim-pathogen/autoload/pathogen.vim ~/.vim/autoload/pathogen
	[ -d ~/.vim/autoload/togglebg.vim ] && rm -rf ~/.vim/autoload/togglebg.vim
	ln -s ~/.codisms/repos/solarized/vim-colors-solarized/autoload/togglebg.vim ~/.vim/autoload/togglebg.vim

	[ ! -d ~/.vim/bitmaps ] && mkdir ~/.vim/bitmaps
	[ -f ~/.vim/bitmaps/togglebg.png ] && rm -f ~/.vim/bitmaps/togglebg.png
	ln -s ~/.codisms/repos/solarized/vim-colors-solarized/bitmaps/togglebg.png ~/.vim/bitmaps/togglebg.png

	[ ! -d ~/.vim/bundle ] && mkdir ~/.vim/bundle
	[ -d ~/.vim/bundle/vim-colors-solarized ] && rm -rf ~/.vim/bundle/vim-colors-solarized
	ln -s ~/.codisms/repos/vim-colors-solarized ~/.vim/bundle/vim-colors-solarized
	#ln -s ~/.codisms/repos/tslime.vim ~/.vim/bundle/tslime.vim
	[ -d ~/.vim/bundle/pgsql.vim ] && rm -rf ~/.vim/bundle/pgsql.vim
	ln -s ~/.codisms/repos/pgsql.vim ~/.vim/bundle/pgsql.vim
	[ -d ~/.vim/bundle/dbext.vim ] && rm -rf ~/.vim/bundle/dbext.vim
	ln -s ~/.codisms/repos/dbext.vim ~/.vim/bundle/dbext.vim
	#ln -s ~/.vim/repos/vim-neatstatus ~/.vim/bundle/vim-neatstatus
	[ -d ~/.vim/bundle/taboo.vim ] && rm -rf ~/.vim/bundle/taboo.vim
	ln -s ~/.codisms/repos/taboo.vim ~/.vim/bundle/taboo.vim
	[ -d ~/.vim/bundle/vim-go ] && rm -rf ~/.vim/bundle/vim-go
	ln -s ~/.codisms/repos/vim-go ~/.vim/bundle/vim-go
	[ -d ~/.vim/bundle/vim-ruby ] && rm -rf ~/.vim/bundle/vim-ruby
	ln -s ~/.codisms/repos/vim-ruby ~/.vim/bundle/vim-ruby

	[ ! -d ~/.vim/colors ] && mkdir ~/.vim/colors
	[ -d ~/.vim/colors/solarized.vim ] && rm -rf ~/.vim/colors/solarized.vim
	ln -s ~/.codisms/repos/solarized/vim-colors-solarized/colors/solarized.vim ~/.vim/colors/solarized.vim

	[ ! -d ~/.vim/doc ] && mkdir ~/.vim/doc
	[ -f ~/.vim/doc/dbext.txt ] && rm -f ~/.vim/doc/dbext.txt
	ln -s ~/.codisms/repos/dbext.vim/doc/dbext.txt ~/.vim/doc/dbext.txt

	installVimExtensions_YCM
}

installLibEvent() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing libevent...
	##read -p 'Press [Enter] to continue...'

	cd ~

	echo Cloning libevent...
	git clone --quiet https://github.com/libevent/libevent.git
	cd libevent
	sh autogen.sh --quiet > /dev/null
	./configure --prefix=/usr/local --quiet > /dev/null
	make --quiet
	make install --quiet
	cd ..
	rm -rf libevent
}

installTmux() {
	installLibEvent

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing tmux...
	##read -p 'Press [Enter] to continue...'

	#sh <(wget -qO- http://s.minos.io/s) -x tmux-2.0f

	cd ~
	echo Cloning tmux...
	git clone --quiet https://github.com/tmux/tmux.git
	cd tmux
	sh autogen.sh --quiet > /dev/null
	./configure --prefix=/usr/local --quiet > /dev/null
	make --quiet
	make install --quiet
	cd ..
	rm -rf tmux

 	PATH=$PATH:`find /usr/local/rvm/rubies/ruby-*/bin/ | head -n 1`

# 	gem --update system
	gem install --quiet tmuxinator

	ln -s .codisms/tmuxinator .tmuxinator
	ln -s ~/.codisms/tmux.conf ~/.tmux.conf
}

installGo() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Installing go...
	##read -p 'Press [Enter] to continue...'

	if [ ! -f /usr/local/go1.5.1.linux-amd64.tar.gz ]; then
		curl 'https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz' -o /usr/local/go1.5.1.linux-amd64.tar.gz
		tar -C /usr/local -xzf /usr/local/go1.5.1.linux-amd64.tar.gz
	fi

	[ ! -d ~/go ] && mkdir ~/go
	[ ! -d ~/go/bin ] && mkdir ~/go/bin
	[ ! -d ~/go/pkg ] && mkdir ~/go/pkg
	[ ! -d ~/go/src ] && mkdir ~/go/src
	[ ! -d ~/go/src/github.com ] && mkdir ~/go/src/github.com
}

startServices() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Starting services...
	##read -p 'Press [Enter] to continue...'

	startMySql

	ln -s ~/.codisms/bin/tunnels /etc/init.d/tunnels
	chkconfig tunnels on
	service tunnels start
}

startMySql() {
	service mysqld start
	chkconfig mysqld on
}

#-----------------------------------------------------------------------------------------------------------
# Download code

downloadCode() {
	downloadCode_Veritone
	downloadCode_HomDna
	downloadCode_Codisms

	cd ~
	echo Cloning ssh_helper... && git clone --quiet https://bitbucket.org/codisms/ssh_helper.git
	echo Cloning db... && git clone --quiet https://bitbucket.org/codisms/db.git

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Getting dependencies for ssh_helper...
	##read -p 'Press [Enter] to continue...'

	cd ssh_helper
	npm install --quiet
	cd ..
	/root/.codisms/bin/ssh-get

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Getting dependencies for veritone-cli...
	##read -p 'Press [Enter] to continue...'

	cd ~/Veritone/node/veritone-cli
	npm install --quiet
	cd ~
}

downloadCode_Codisms() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Downloading codisms...
	##read -p 'Press [Enter] to continue...'

	[ ! -d ~/Codisms ] && mkdir ~/Codisms
	cd ~/Codisms/

	# nothing here

	[ ! -d ~/go ] && mkdir ~/go
	[ ! -d ~/go/src ] && mkdir ~/go/src
	[ ! -d ~/go/src/github.com ] && mkdir ~/go/src/github.com
	[ ! -d ~/go/src/github.com/codisms ] && mkdir ~/go/src/github.com/codisms

	cd ~/go/src/github.com/codisms
	echo Cloning color-console... && git clone --quiet https://github.com/codisms/color-console
	echo Cloning json-config... && git clone --quiet https://github.com/codisms/json-config
}

downloadCode_Veritone() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Downloading veritone...
	##read -p 'Press [Enter] to continue...'

	cd ~
	mkdir Veritone
	cd Veritone
	echo Cloning gracenote-sdk... && git clone --quiet https://github.com/veritone/gracenote-sdk.git
	echo Cloning database... && git clone --quiet https://github.com/inspirent/database.git
	echo Cloning core-database... && git clone --quiet https://github.com/inspirent/core-database.git
	echo Cloning datacenter-config... && git clone --quiet https://github.com/inspirent/datacenter-config.git
	echo Cloning core-documentation... && git clone --quiet https://github.com/veritone/core-documentation.git

	mkdir node
	cd node
	echo Cloning task-transcode-ffmpeg... && git clone --quiet https://github.com/veritone/task-transcode-ffmpeg.git
	echo Cloning transcript-streamer... && git clone --quiet https://github.com/inspirent/transcript-streamer.git
	echo Cloning core-logger... && git clone --quiet https://github.com/veritone/core-logger.git
	echo Cloning core-test... && git clone --quiet https://github.com/veritone/core-test.git
	echo Cloning task-record-from-stream... && git clone --quiet https://github.com/veritone/task-record-from-stream.git
	echo Cloning rest-streaming... && git clone --quiet https://github.com/nestlabs/rest-streaming.git
	echo Cloning core-analytics-server... && git clone --quiet https://github.com/veritone/core-analytics-server.git
	echo Cloning task-nuance-server... && git clone --quiet https://github.com/veritone/task-nuance-server.git
	echo Cloning task-webhook... && git clone --quiet https://github.com/veritone/task-webhook.git
	echo Cloning core-batch-server... && git clone --quiet https://github.com/veritone/core-batch-server.git
	echo Cloning azure-submit... && git clone --quiet https://github.com/veritone/azure-submit.git
	echo Cloning task-iron-server... && git clone --quiet https://github.com/veritone/task-iron-server.git
	echo Cloning media-streamer... && git clone --quiet https://github.com/veritone/media-streamer.git
	echo Cloning core-search-server... && git clone --quiet https://github.com/veritone/core-search-server.git
	echo Cloning core-admin... && git clone --quiet https://github.com/inspirent/core-admin.git
	echo Cloning core-job-server... && git clone --quiet https://github.com/veritone/core-job-server.git
	echo Cloning node-vlf... && git clone --quiet https://github.com/veritone/node-vlf.git
	echo Cloning node-ffmpeg... && git clone --quiet https://github.com/veritone/node-ffmpeg.git
	echo Cloning endpoint-broker... && git clone --quiet https://github.com/veritone/endpoint-broker.git
	echo Cloning submit-email... && git clone --quiet https://github.com/veritonemedia/submit-email.git
	echo Cloning task-transcribe... && git clone --quiet https://github.com/veritone/task-transcribe.git
	echo Cloning task-download-file... && git clone --quiet https://github.com/veritone/task-download-file.git
	echo Cloning watcher-dropbox-worker... && git clone --quiet https://github.com/veritone/watcher-dropbox-worker.git
	echo Cloning task-sediment-server... && git clone --quiet https://github.com/veritone/task-sediment-server.git
	echo Cloning veritone-api... && git clone --quiet https://github.com/veritone/veritone-api.git
	echo Cloning task-speechpad... && git clone --quiet https://github.com/veritone/task-speechpad.git
	echo Cloning node-cache... && git clone --quiet https://github.com/inspirent/node-cache.git
	echo Cloning frontend... && git clone --quiet https://github.com/inspirent/frontend.git
	echo Cloning node-azure-media... && git clone --quiet https://github.com/veritone/node-azure-media.git
	echo Cloning task-mention-generate... && git clone --quiet https://github.com/veritone/task-mention-generate.git
	echo Cloning core-application-server... && git clone --quiet https://github.com/veritone/core-application-server
	echo Cloning datacenter... && git clone --quiet https://github.com/inspirent/datacenter.git
	echo Cloning node-config... && git clone --quiet https://github.com/inspirent/node-config.git
	echo Cloning core-report-server... && git clone --quiet https://github.com/veritone/core-report-server.git
	echo Cloning cms... && git clone --quiet https://github.com/veritone/cms.git
	echo Cloning node-logger... && git clone --quiet https://github.com/inspirent/node-logger.git
	echo Cloning core-server-base... && git clone --quiet https://github.com/veritone/core-server-base.git
	echo Cloning core-recording-server... && git clone --quiet https://github.com/veritone/core-recording-server.git
	echo Cloning admin-ui... && git clone --quiet https://github.com/inspirent/admin-ui.git
	echo Cloning ffmpeg-test-data... && git clone --quiet https://github.com/veritone/ffmpeg-test-data.git
	echo Cloning node-server-base... && git clone --quiet https://github.com/inspirent/node-server-base.git
	echo Cloning task-gracenote... && git clone --quiet https://github.com/veritone/task-gracenote.git
	echo Cloning transcoder... && git clone --quiet https://github.com/veritone/transcoder.git
	echo Cloning veritone-cli... && git clone --quiet https://github.com/veritone/veritone-cli.git
	echo Cloning politics-frontend... && git clone --quiet https://github.com/inspirent/politics-frontend.git
	echo Cloning watcher-dropbox-server... && git clone --quiet https://github.com/veritone/watcher-dropbox-server.git

	[ ! -d ~/go ] && mkdir ~/go
	[ ! -d ~/go/src ] && mkdir ~/go/src
	[ ! -d ~/go/src/github.com ] && mkdir ~/go/src/github.com

	[ ! -d ~/go/src/github.com/veritone ] && mkdir ~/go/src/github.com/veritone
	cd ~/go/src/github.com/veritone
	echo Cloning azure-polling... && git clone --quiet https://github.com/veritone/azure-polling.git
	echo Cloning go-veritone-api... && git clone --quiet https://github.com/veritone/go-veritone-api.git
	echo Cloning core-workflow... && git clone --quiet https://github.com/veritone/core-workflow.git
	echo Cloning email-worker... && git clone --quiet https://github.com/veritone/email-worker.git
	echo Cloning youtube-ripper... && git clone --quiet https://github.com/veritone/youtube-ripper.git
	echo Cloning youtube-das... && git clone --quiet https://github.com/veritone/youtube-das
	echo Cloning podcast-ripper... && git clone --quiet https://github.com/veritone/podcast-ripper.git
	echo Cloning task-fingerprint-audio-server... && git clone --quiet https://github.com/veritone/task-fingerprint-audio-server.git
	echo Cloning azure-submit... && git clone --quiet https://github.com/veritone/azure-submit.git
	echo Cloning subscription-das... && git clone --quiet https://github.com/veritone/subscription-das.git
	echo Cloning youtube-service... && git clone --quiet https://github.com/veritone/youtube-service.git
	echo Cloning go-iron-worker-helpers... && git clone --quiet https://github.com/veritone/go-iron-worker-helpers.git
	echo Cloning veritone-workers... && git clone --quiet https://github.com/veritone/veritone-workers.git
	echo Cloning go-lattice... && git clone --quiet https://github.com/veritone/go-lattice.git
	echo Cloning youtube-mcn-import... && git clone --quiet https://github.com/veritone/youtube-mcn-import.git
	echo Cloning mention-notification-worker... && git clone --quiet https://github.com/veritone/mention-notification-worker.git

	[ ! -d ~/go/src/github.com/inspirent ] && mkdir ~/go/src/github.com/inspirent
	cd ~/go/src/github.com/inspirent
	echo Cloning crontab-generator... && git clone --quiet https://github.com/inspirent/crontab-generator.git
	echo Cloning mp-youtube-das... && git clone --quiet https://github.com/inspirent/mp-youtube-das.git
	echo Cloning youtube-video-metrics... && git clone --quiet https://github.com/inspirent/youtube-video-metrics.git
	echo Cloning mention-generate-by-tracking-unit... && git clone --quiet https://github.com/inspirent/mention-generate-by-tracking-unit.git
	echo Cloning sso-auth... && git clone --quiet https://github.com/inspirent/sso-auth.git
	echo Cloning server-base... && git clone --quiet https://github.com/inspirent/server-base.git
	echo Cloning youtube-channel-metrics... && git clone --quiet https://github.com/inspirent/youtube-channel-metrics.git
	echo Cloning go-iron-worker-helpers... && git clone --quiet https://github.com/inspirent/go-iron-worker-helpers.git
	echo Cloning notifications... && git clone --quiet https://github.com/inspirent/notifications.git
	echo Cloning mp-advertiser-mgmt-server... && git clone --quiet https://github.com/inspirent/mp-advertiser-mgmt-server.git
	echo Cloning iron-io... && git clone --quiet https://github.com/inspirent/iron-io.git
	echo Cloning mp-broadcaster-das... && git clone --quiet https://github.com/inspirent/mp-broadcaster-das.git
	echo Cloning go-spooky... && git clone --quiet https://github.com/inspirent/go-spooky.git
	echo Cloning mp-analytics-das... && git clone --quiet https://github.com/inspirent/mp-analytics-das.git
	echo Cloning logger... && git clone --quiet https://github.com/inspirent/logger.git
	echo Cloning data-access-authority... && git clone --quiet https://github.com/inspirent/data-access-authority.git
	echo Cloning veritone-util... && git clone --quiet https://github.com/inspirent/veritone-util.git
	echo Cloning youtube-util... && git clone --quiet https://github.com/inspirent/youtube-util
	echo Cloning sso-mgmt... && git clone --quiet https://github.com/inspirent/sso-mgmt.git
	echo Cloning go-veritone-search... && git clone --quiet https://github.com/inspirent/go-veritone-search.git
	echo Cloning mp-metrics-server... && git clone --quiet https://github.com/inspirent/mp-metrics-server.git
	echo Cloning stream-ripper... && git clone --quiet https://github.com/inspirent/stream-ripper.git
	echo Cloning mp-das... && git clone --quiet https://github.com/inspirent/mp-das.git
	echo Cloning mention-generate-by-media... && git clone --quiet https://github.com/inspirent/mention-generate-by-media.git
	echo Cloning user-mgmt-server... && git clone --quiet https://github.com/inspirent/user-mgmt-server.git
	echo Cloning cron-collection-stats... && git clone --quiet https://github.com/inspirent/cron-collection-stats.git
	echo Cloning tv-ripper... && git clone --quiet https://github.com/inspirent/tv-ripper.git
	echo Cloning cn-collection-mgmt... && git clone --quiet https://github.com/inspirent/cn-collection-mgmt.git
	echo Cloning mp-broadcaster-mgmt-server... && git clone --quiet https://github.com/inspirent/mp-broadcaster-mgmt-server.git
}

downloadCode_HomDna() {

	echo
	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	echo Downloading homedna...
	##read -p 'Press [Enter] to continue...'

	cd ~
	mkdir HomDNA
	cd HomDNA

	mkdir node
	cd node
	echo Cloning homdna-mobile... && git clone --quiet https://github.com/homdna/homdna-mobile.git

	[ ! -d ~/go ] && mkdir ~/go
	[ ! -d ~/go/src ] && mkdir ~/go/src
	[ ! -d ~/go/src/github.com ] && mkdir ~/go/src/github.com
	[ ! -d ~/go/src/github.com/homdna ] && mkdir ~/go/src/github.com/homdna

	cd ~/go/src/github.com/homdna
	echo Cloning appliance-service... && git clone --quiet https://github.com/homdna/appliance-service.git
	echo Cloning notification-service... && git clone --quiet https://github.com/homdna/notification-service.git
	echo Cloning homdna-service... && git clone --quiet https://github.com/homdna/homdna-service.git
}



############################################################################################################
# BEGIN
############################################################################################################

if [ "$1" != "" ]; then
	setHostName $1

# 	echo
# 	echo Rebooting machine for changes to take effect...
# 	read -p 'Press [Enter] to continue...'
# 	reboot
# 	exit
fi

cd ~
echo Installing git...
yum -y -q install git
echo
echo
echo
echo 'Cloning .codisms; enter bitbucket.org password for "codisms":'
echo Cloning dev-config...
git clone --quiet https://codisms@bitbucket.org/codisms/dev-config.git .codisms

echo Configuring security...
configureSecurity

echo Downloading submodules...
cd ~/.codisms
git submodule --quiet update --init --recursive
cd ~

#-----------------------------------------------------------------------------------------------------------
# Create a SSH key, if needed

# if [ ! -f ~/.ssh/id_rsa ]; then
#
# 	echo
# 	echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# 	echo Generating SSH key...
# 	##read -p 'Press [Enter] to continue...'
#
# 	echo
# 	ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
# fi

#-----------------------------------------------------------------------------------------------------------
# Do it!

echo
echo
echo ---------------------------------------------------------------
echo Ready to configure environment
#read -p 'Press [Enter] to continue...'
echo

configureEnvironment

echo
echo
echo ---------------------------------------------------------------
echo Ready to install packages
#read -p 'Press [Enter] to continue...'
echo

installPackages

echo
echo
echo ---------------------------------------------------------------
echo Ready to download code
#read -p 'Press [Enter] to continue...'
echo

downloadCode

# echo
# echo
# echo Generated public key:
# echo
# cat ~/.ssh/id_rsa.pub
# echo
# #read -p 'Press [Enter] to continue...'

echo
echo
echo ---------------------------------------------------------------
echo Done.  Ready to reboot
read -p 'Press [Enter] to continue...'
echo

reboot
