#!/bin/sh
 
sudo apt-get update
sudo apt-get -y upgrade
 
sudo dpkg-reconfigure tzdata
sudo apt-get -y install console-data locales
sudo dpkg-reconfigure console-data
sudo dpkg-reconfigure locales
 
sudo apt-get -y remove --purge `sudo dpkg --get-selections | grep "\-dev\|python\|x11\|sound\|midori\|lxde\|omxplayer\|raspi\-config" | sed s/install//`
sudo apt-get -y remove `sudo dpkg --get-selections | grep -v "deinstall" | grep ssh | sed s/install//`
sudo apt-get -y install dropbear
 
sudo apt-get -y remove gcc-4.4-base:armhf gcc-4.5-base:armhf gcc-4.6-base:armhf
sudo apt-get -y remove ca-certificates libraspberrypi-doc xkb-data fonts-freefont-ttf locales manpages
 
sudo apt-get -y remove --purge xserver-xorg xserver-xorg-core xfonts-utils xarchiver x11-utils x11-common wpagui
sudo apt-get -y remove --purge cifs-utils samba-common smbclient nfs-common
sudo apt-get -y remove --purge liblapack3 libatlas3-base penguinspuzzle gdb menu menu-xdg xdg-utils desktop-file-utils raspberrypi-artwork
sudo apt-get -y remove --purge libiw30 wpa-supplicant wireless-tools
sudo apt-get -y remove --purge parted dpkg-dev
 
sudo apt-get -y autoremove
 
sudo apt-get clean

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
