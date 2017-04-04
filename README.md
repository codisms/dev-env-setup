This script is to help create new instances of my dev environments.  Not intended for public consumption.

----

To install and change host name:

`curl -sSL https://bitbucket.org/codisms/dev-setup/raw/master/setup.sh | bash -s <host_name>`

To install without changing host name:

`curl -sSL https://bitbucket.org/codisms/dev-setup/raw/master/setup.sh | bash -s`

----

Setting console to 1024x768 in CentOS 7:

1. `sudo vi /etc/default/grub`
2. Add `vga=792` inside the "-quotes for `GRUB_CMDLINE_LINUX`, (ex. `GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet vga=792"`)
3. Save and exit Vi.
4. `grub2-mkconfig -o /boot/grub2/grub.cfg`
5. `reboot`

(https://superuser.com/questions/816528/with-centos-7-as-a-virtualbox-guest-on-a-mac-host-how-can-i-change-the-screen-r)

----

Installing Parallels tools:

1. `mkdir -p /media/cdrom`
2. `mount -o exec /dev/cdrom /media/cdrom`
3. `cd /media/cdrom`
4. `./install`