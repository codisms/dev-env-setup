echo "Installing fonts..."
retry pip install --user powerline-status

## https://gist.github.com/renshuki/3cf3de6e7f00fa7e744a
#mkdir -p ~/.fonts
#mkdir -p ~/.config/fontconfig/conf.d

#curl https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -o ~/.fonts/PowerlineSymbols.otf -L
#curl https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -o ~/.config/fontconfig/conf.d/10-powerline-symbols.conf -L

#fc-cache -vf ~/.fonts/
