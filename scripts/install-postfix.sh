
echo "postfix postfix/mailname string $(hostname)" | sudo debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Local only'" | sudo debconf-set-selections

apt_get_install postfix

