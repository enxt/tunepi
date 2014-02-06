#!/bin/sh
 
sudo apt-get update
sudo apt-get -y upgrade
 
sudo dpkg-reconfigure tzdata
sudo apt-get -y install console-data locales
sudo dpkg-reconfigure console-data
sudo dpkg-reconfigure locales
 
sudo apt-get -y remove --purge `sudo dpkg --get-selections | grep "\-dev\|python\|x11\|sound\|midori\|lxde\|omxplayer\|raspi\-config\|v4l" | sed s/install//`
sudo apt-get -y remove `sudo dpkg --get-selections | grep -v "deinstall" | grep ssh | sed s/install//`
sudo apt-get -y install dropbear


## Various removes
sudo apt-get -y remove --purge gnome-themes-standard-data liblapack3 libatlas3-base penguinspuzzle \
gdb menu menu-xdg xdg-utils desktop-file-utils raspberrypi-artwork java-common \
ca-certificates libraspberrypi-doc xkb-data fonts-freefont-ttf locales manpages \
gcc-4.4-base:armhf gcc-4.5-base:armhf gcc-4.6-base:armhf

## Comment above line if you want wireless connections.
sudo apt-get -y remove --purge libiw30 wpasupplicant wireless-tools

## Comment above line if you want samba
sudo apt-get -y remove --purge cifs-utils samba-common smbclient nfs-common

## Comment above if you work in console (i´m work through ssh)
sudo apt-get -y remove --purge locales


sudo apt-get -y autoremove
 
sudo apt-get clean

sudo rm -rf /etc/wpa_supplicant
sudo rm -rf /etc/X11
sudo rm -rf ~/python_games
sudo rm -rf /opt
 
sudo swapoff -a
cd /var
sudo dd if=/dev/zero of=swap bs=1M count=100
mkswap /var/swap
 
cd /var/log/
sudo rm `find . -type f`
 
#####################   NEXT   #################################
 
#Read more: http://www.cnx-software.com/2012/07/31/84-mb-minimal-raspbian-armhf-image-for-raspberry-pi/#ixzz2sI9E8exY
 
#sudo shutdown now
#sudo dd if=/dev/sdb of=image_name.img count=3788800
#mkdir mnt
#sudo mount -o loop,offset=$((512*122880)) image_name.img mnt
#sudo sfill -z -l -l -f mnt
#sudo umount mnt
#7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on image_name.img.7z image_name.img
