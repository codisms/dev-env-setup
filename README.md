This script is to help create new instances of my dev environments.  Not intended for public consumption.

----

To install and change host name:

`curl -sSL -H 'Cache-Control: no-cache' https://bitbucket.org/codisms/dev-setup/raw/master/setup.sh | bash -s <host_name>`

To install without changing host name:

`curl -sSL -H 'Cache-Control: no-cache' https://bitbucket.org/codisms/dev-setup/raw/master/setup.sh | bash -s`

----

Setting console to 1024x768 in CentOS 7:

1. `sudo vi /etc/default/grub`
2. Add `vga=792` inside the "-quotes for `GRUB_CMDLINE_LINUX`, (ex. `GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet vga=792"`)
3. Save and exit Vi.
4. `grub2-mkconfig -o /boot/grub2/grub.cfg`
5. `reboot`

(https://superuser.com/questions/816528/with-centos-7-as-a-virtualbox-guest-on-a-mac-host-how-can-i-change-the-screen-r)

----

Enable SSH (Ubuntu 16.04):

1. `sudo apt-get install openssh-server`
2. `sudo service ssh status`


----

Execute sudo without password (Ubuntu 16.04):

1. `sudo visudo`
2. Add line `jbailey ALL=(ALL) NOPASSWD: ALL`

----

Installing Parallels tools:

1. `mkdir -p /media/cdrom`
2. `mount -o exec /dev/cdrom /media/cdrom`
3. `cd /media/cdrom`
4. `./install`

----

Ubuntu hints:

```
sudo apt install -y git mercurial bzr subversion \
	gcc gpp linux-kernel-headers kernel-package \
	automake cmake make libtool \
	libncurses-dev tcl-dev \
	curl libcurl4-openssl-dev clang ctags wget unzip \
	python python-dev golang ruby \
	perl libperl-dev perl-modules \
	dnsutils mutt elinks telnet \
	man htop zsh \
	redis-server \
	apache2 \
	php5-cli php5-mysql openjdk-8-jre \
	libdbd-odbc-perl freetds-bin freetds-common freetds-dev \
	libevent-2* libevent-dev \
	yum-utils \
	openssh-client openconnect \
	docker \
	sysstat iotop traceroute \
	network-manager-vpnc
```

```
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
```

`mv .dircolors .dir_colors`

`sudo update-alternatives --config editor`
`sudo add-apt-repository ppa:jonathonf/vim`

VPN config at /etc/NetworkManager/system-connections/Zodiac:
```
[connection]
id=Zodiac
uuid=1c56a5af-58eb-4da2-850f-ae8c709c7ed9
type=vpn
permissions=user:jbailey:;
autoconnect=false

[vpn]
service-type=org.freedesktop.NetworkManager.vpnc
NAT Traversal Mode=natt
Vendor=cisco
Xauth username=<username>
IPSec gateway=vpn.imsco-us.com
IPSec ID=SVNVPN
Perfect Forward Secrecy=server
IKE DH Group=dh2
Local Port=0

[vpn-secrets]
IPSec secret=$vNVpN14
Xauth password=<password>

[ipv4]
method=auto
never-default=true
```
