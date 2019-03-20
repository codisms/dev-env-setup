
echo "postfix postfix/mailname string $(hostname)" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections

apt_get_install postfix

