*Note:* This repository currently only supports Ubuntu 20.04 or above.  (Ubuntu 16.04 and 18.04 might work.) CentOS currently is not enabled.

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
  - Database drivers: FreeTDS (Microsoft SQL)
  - Tools: zsh, unzip, htop, sysstat, iotop, certbot, aws-cli, glances, rename, Terraform, Docker, Kubernetes
  - Servers: apache2, redis, postgresql
  - Network tools: Google Chrome, openconnect, dnsutils, mutt, elinks, telnet, wget, traceroute, iftop, network-manager-vpnc, aria2
- Apache modules enabled: proxy, proxy_http, proxy_wstunnel, rewrite, auth_basic, proxy_balancer, proxy_html, proxy_connect, ssl, xml2enc, substitute, macro, include, headers
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
  [--debug] [--private-repo=<repo_url>] [--host=<hostname>] [--bash]
```
Where:
- `--debug` enabled verbose logging
- `--private-repo=` specifies the private repo you wish to download and install
- `--host=` specifies the new host name for this instance
- `--bash` specifies that bash should be the default shell (default is zsh)

## Other notes

### Installing Parallels tools:
For virtualized environments.
```
mkdir -p /media/cdrom
mount -o exec /dev/cdrom /media/cdrom
cd /media/cdrom
./install
```
