This script is to help create new instances of my dev environments.  Not intended for public consumption.

----

To install:
```
curl -sSL -H 'Cache-Control: no-cache' https://bitbucket.org/codisms/dev-setup/raw/master/setup.sh | bash -s [--host=<hostname>] [--debug] [--skip-repo] [--repo-password=<password>]
```

For this script to work, you must have `curl` and `git` installed:
```
sudo apt-get install -y git curl
sudo yum install -y git curl
```

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

```
sudo apt-get install openssh-server
sudo service ssh status
mkdir ~/.ssh
vi .ssh/authorized_keys

<paste in public key; exit>

chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

----

Installing Parallels tools:

```
mkdir -p /media/cdrom
mount -o exec /dev/cdrom /media/cdrom
cd /media/cdrom
./install
```
