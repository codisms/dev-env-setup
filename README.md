*Note:* This repository currently only supports Ubuntu 16.04 or above.   CentOS needs testing and updating.

## Description
This script is to help create new instances of my dev environments with the following:

- Add current user to sudoers file
- Updates all currently installed packages (`agt-get upgrade`)
- Creates a swap file on for instances with small memory resources
- Optionally changes host name (see `--host` parameter)
- Packages installed:
  - apt-fast
  - Build tools: make, automake, gcc, gpp, cmake, clang, ctags
  - Languages: perl, python, python3, Go, Ruby, Node, PHP, OpenJDK
  - Database drives: FreeTDS (Microsoft SQL)
  - Tools: zsh, unzip, htop, sysstat, iotop, certbot, aws-cli
  - Servers: apache2, redis, postgresql
  - Network tools: Google Chrome, openconnect, dnsutils, mutt, elinks, telnet, wget, traceroute, iftop, network-manager-vpnc, aria2
- Apache modules enabled: proxy, proxy_http, proxy_wstunnel, rewrite, auth_basic, proxy_balancer, proxy_html, proxy_connect, ssl, xml2enc, substitute
- Most recent builds of vim and tmux with my configurations ([vim](https://github.com/codisms/vim-config), [tmux](https://github.com/codisms/tmux-config))
- My settings for the following (from [env-config](https://github.com/codisms/env-config)):
  - zsh
  - muttrc
  - elinks
  - git
  - ctags-
  - editorconfig
  - eslint
  - psql
- Configures daily, weekly, monthly cron jobs to maintain the latest versions of vim and tmux while clearing tmux resurrect plugin files
- Optionally downloads and installs another repo specified with the `--private-repo` parameter into `~/.dotfiles.private`

## Installation
### Prerequisites
For this script to work, you must have `curl` and `git` installed:
```
sudo apt-get install -y git curl
sudo yum install -y git curl
```

### Installation
To install:
```
curl -sSL https://raw.githubusercontent.com/codisms/dev-env-setup/master/setup.sh | bash -s -- \
  [--debug] [--private-repo=<repo_url>] [--host=<hostname>]
```
Where:
- `--debug` enabled verbose logging
- `--private-repo=` specifies the private repo you wish to download and install
- `--host=` specifies the new host name for this instance

## Other notes

### Setting console to 1024x768 in CentOS 7
1. `sudo vi /etc/default/grub`
2. Add `vga=792` inside the "-quotes for `GRUB_CMDLINE_LINUX`, (ex. `GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet vga=792"`)
3. Save and exit Vi.
4. `grub2-mkconfig -o /boot/grub2/grub.cfg`
5. `reboot`

(https://superuser.com/questions/816528/with-centos-7-as-a-virtualbox-guest-on-a-mac-host-how-can-i-change-the-screen-r)

### Enable SSH (Ubuntu 16.04):
```
sudo apt-get install openssh-server
sudo service ssh status
mkdir ~/.ssh
vi .ssh/authorized_keys

<paste in public key; exit>

chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Installing Parallels tools:
```
mkdir -p /media/cdrom
mount -o exec /dev/cdrom /media/cdrom
cd /media/cdrom
./install
```
