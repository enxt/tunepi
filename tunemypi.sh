sudo su

dpkg-reconfigure tzdata
apt-get install console-data locales
dpkg-reconfigure console-data
dpkg-reconfigure locales


rm -rf /home/pi/python_games

apt-get --purge remove midori omxplayer raspi-config
apt-get --purge remove `dpkg --get-selections | grep "\-dev" | sed s/install//`
#apt-get --purge remove `dpkg --get-selections | grep "libdev" | sed s/install//`
apt-get --purge remove `dpkg --get-selections | grep -v "deinstall" | grep python | sed s/install//`
apt-get --purge remove `dpkg --get-selections | grep -v "deinstall" | grep x11 | sed s/install//`
apt-get --purge remove `dpkg --get-selections | grep -v "deinstall" | grep gtk | sed s/install//`
apt-get --purge remove `dpkg --get-selections | grep -v "deinstall" | grep lxde | sed s/install//`
apt-get --purge remove `dpkg --get-selections | grep -v "deinstall" | grep sound | sed s/install//`

#apt-get --purge remove `dpkg --get-selections | grep -v "deinstall" | grep ssh | sed s/install//`
#apt-get install dropbear

swapoff -a
cd /var
dd if=/dev/zero of=swap bs=1M count=100

cd /var/log/
rm `find . -type f`



apt-get --purge remove aptitude aptitude-common binutils cifs-utils console-setup console-setup-linux cpp \
cpp-4.6 curl dbus debian-reference-common debian-reference-en desktop-file-utils git \
git-core info libboost-iostreams1.46.1 libboost-iostreams1.48.0 libboost-iostreams1.49.0 \
libboost-iostreams1.50.0 libcurl3 libcurl3-gnutls libcwidget3 libdbus-1-3 libept1.4.12 \
libexpat1 libffi5 libglib2.0-0 libgmp10 libiw30 libldap-2.4-2 libmpc2 libmpfr4 \
libnih-dbus1 libnl-3-200 libnl-genl-3-200 libpci3 libpcsclite1 libpng12-0 librtmp0 \
libsasl2-2 libsasl2-modules libsqlite3-0 libssh2-1 libsystemd-login0 libtalloc2 \
libwbclient0 libxapian22 libxml2 lua5.1 luajit lxde-icon-theme man-db menu-xdg \
mountall pciutils penguinspuzzle pkg-config pypy-upstream rpi-update sgml-base \
shared-mime-info smbclient strace tasksel tasksel-data wireless-tools wpasupplicant \
xdg-utils xml-core gettext-base git-man libasprintf0c2 liberror-perl libglib2.0-data \
libluajit-5.1-common libtdb1 menu patch rsync samba-common ucf libreadline5 xkb-data

apt-get --purge autoremove && apt-get clean


apt-get update && apt-get install vim && update-alternatives --set editor /usr/bin/vim.basic

adduser tunepiuser

visudo

## Look for this section
#pi ALL=(ALL) NOPASSWD: ALL
#tunepiuser ALL=(ALL) NOPASSWD: ALL

sudo userdel pi
sudo groupdel pi
sudo visudo

## Look for this section
#pi ALL=(ALL) NOPASSWD: ALL
## ^ Delete this line
#tunepiuser ALL=(ALL) NOPASSWD: ALL

sudo vi /etc/ssh/sshd_config
PermitRootLogin yes ---> PermitRootLogin no

sudo service ssh restart


vi /etc/iptables-rules

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT 
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 
-A INPUT -i eth0 -p tcp -m tcp --dport 22 -j ACCEPT 
-A INPUT -i eth0 -p tcp -m tcp --dport 443 -j ACCEPT
-A INPUT -i eth0 -p tcp -m tcp --dport 80 -j ACCEPT
# Allow ICMP packets necessary for MTU path discovery
-A INPUT -p icmp --icmp-type fragmentation-needed -j ACCEPT
# Allow echo request
-A INPUT -p icmp --icmp-type 8 -j ACCEPT
-A INPUT -j DROP 
COMMIT

iptables-restore < /etc/iptables-rules





vi /etc/network/interfaces

# Remove any existing mention of eth0 and replace with:
auto eth0
iface eth0 inet dhcp
 pre-up /sbin/iptables-restore < /etc/iptables-rules




 vi /boot/config.txt
force_turbo=0
arm_freq_min=100
# You could allow it to scale up to 1000 here, but I don't.
#arm_freq=1000


sudo apt-get install cpufrequtils


sudo cpufreq-set -g ondemand


sudo apt-get -y update && sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove && sudo apt-get -y autoclean

wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update

rpi-update 240



sudo apt-get install vim vim-nox screen unzip zip python-software-properties aptitude curl ntp ntpdate git-core wget ca-certificates binutils raspi-config -y

sudo apt-get install dropbear openssh-client
sudo /etc/init.d/ssh stop
sudo sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sudo sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-w"/g' /etc/default/dropbear #prevent root logins
sudo sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-s"/g' /etc/default/dropbear #prevent password logins
sudo sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-g"/g' /etc/default/dropbear #prevent password logins for root
sudo sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-w -s"/g' /etc/default/dropbear #prevent root logins and prevent password logins
sudo sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=2222/g' /etc/default/dropbear
sudo /etc/init.d/dropbear start
sudo apt-get purge openssh-server

sudo sed -i '/[2-6]:23:respawn:\/sbin\/getty 38400 tty[2-6]/s%^%#%g' /etc/inittab #tty2-tty6 will be disabled. We are keeping tty1 for console, unless you choose to disable it.
sudo sed -i '/T0:23:respawn:\/sbin\/getty -L ttyAMA0 115200 vt100/s%^%#%g' /etc/inittab #disable getty on the Raspberry Pi serial line


sudo dpkg-reconfigure dash

sudo echo "CONF_SWAPSIZE=512" > /etc/dphys-swapfile

sudo dphys-swapfile setup

sudo dphys-swapfile swapon

sudo sed -i 's/vm.swappiness=1/vm.swappiness=10/g'  /etc/sysctl.conf

sudo echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf

sudo sed -i 's/defaults,noatime/defaults,noatime,nodiratime/g' /etc/fstab #optimize mount

sudo echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disableipv6.conf #disable ipv6

sudo echo 'blacklist ipv6' >> /etc/modprobe.d/blacklist

sudo sed -i '/::/s%^%#%g' /etc/hosts #Remove IPv6 hosts


sudo echo -e "force_turbo=0" >> /boot/config.txt

sudo sed -i 's/deadline/noop/g' /boot/cmdline.txt


sudo cp -f /etc/network/interfaces /etc/network/interfaces.dhcp-backup

replace:
iface eth0 inet dhcp

with:
iface eth0 inet static
#set your static IP below
address 192.168.1.107

#set your default gateway IP here
gateway 192.168.1.1

netmask 255.255.255.0
network 192.168.1.0
broadcast 192.168.1.255