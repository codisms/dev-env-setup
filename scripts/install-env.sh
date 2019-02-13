printSubHeader "Installing env-config..."
if [ $USE_BASH -eq 1 ]; then
	curl -sSL https://github.com/codisms/env-config/raw/master/install.sh | bash -s
else
	curl -sSL https://github.com/codisms/env-config/raw/master/install.sh | bash -s -- --bash
fi

reloadEnvironment
