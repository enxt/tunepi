#!/bin/sh

# Download and write this image to your sd card
# http://files2.linuxsystems.it/raspbian_wheezy_20130923.img.7z
# don't forget resize swap and root partitions before boot from pi, moving first swap to last of disk.

address=192.168.1.21
gateway=192.168.1.1
netmask=255.255.255.0
broadcast=192.168.1.255
network=192.168.1.0
sshport=2222


apt-get update

dpkg-reconfigure tzdata
dpkg-reconfigure console-data
dpkg-reconfigure locales

cat <<EOF > /etc/iptables-rules
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
EOF

iptables-restore < /etc/iptables-rules


cp -f /etc/network/interfaces /etc/network/interfaces.dhcp-backup

if [ "$address" != "" ]; then
cat <<EOF > /etc/network/interfaces
iface eth0 inet static
 #set your static IP below
 address $address

 #set your default gateway IP here
 gateway $gateway

 netmask $netmask
 network $network
 broadcast $broadcast
 pre-up /sbin/iptables-restore < /etc/iptables-rules

EOF
else
 echo "pre-up /sbin/iptables-restore < /etc/iptables-rules" >> /etc/network/interfaces
fi

exitstest=`cat /boot/config.txt | grep "force_turbo=0"`
if [ $? -eq 1 ]; then
  echo "force_turbo=0" >> /boot/config.txt
  echo "arm_freq_min=100" >> /boot/config.txt
fi

apt-get install -y cpufrequtils
cpufreq-set -g ondemand


apt-get -y install vim vim-nox 
#screen unzip zip python-software-properties curl ntp ntpdate git-core wget ca-certificates binutils -y

apt-get -y install dropbear openssh-client
/etc/init.d/ssh stop
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
#sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-w"/g' /etc/default/dropbear #prevent root logins
#sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-s"/g' /etc/default/dropbear #prevent password logins
#sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-g"/g' /etc/default/dropbear #prevent password logins for root
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-w -s"/g' /etc/default/dropbear #prevent root logins and prevent password logins
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=$sshport/g' /etc/default/dropbear
/etc/init.d/dropbear start
apt-get remove --purge openssh-server

sed -i '/[2-6]:23:respawn:\/sbin\/getty 38400 tty[2-6]/s%^%#%g' /etc/inittab #tty2-tty6 will be disabled. We are keeping tty1 for console, unless you choose to disable it.
sed -i '/T0:23:respawn:\/sbin\/getty -L ttyAMA0 115200 vt100/s%^%#%g' /etc/inittab #disable getty on the Raspberry Pi serial line


dpkg-reconfigure dash

echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf

sed -i 's/defaults,noatime/defaults,noatime,nodiratime/g' /etc/fstab #optimize mount

# disable ipv6
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disableipv6.conf #disable ipv6
echo 'blacklist ipv6' >> /etc/modprobe.d/blacklist
sed -i '/::/s%^%#%g' /etc/hosts #Remove IPv6 hosts

sed -i 's/deadline/noop/g' /boot/cmdline.txt

apt-get -y install nginx
apt-get -y install php5 php5-cgi php5-sqlite php5-common php5-cli php5-fpm php5-gd sqlite3 php5-curl

apt-get -y install php5-dev php5-mysql gcc make
apt-get -y install git mercurial
git clone git://github.com/phalcon/cphalcon.git
cd cphalcon/build/
./install


cat <<EOF > /etc/nginx/sites-enabled/dev.mysite.com
server {

    listen   80;
    server_name dev.mysite.com;

    index index.php index.html index.htm;
    set $root_path '/usr/share/nginx/www/dev.mysite.com';
    root $root_path;

    #try_files $uri $uri/ @rewrite;

    #location @rewrite {
    #    rewrite ^/(.*)$ /index.php?_url=/$1;
    #}

    location ~ \.php {
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index /index.php;

        include /etc/nginx/fastcgi_params;

        fastcgi_split_path_info       ^(.+\.php)(/.+)$;
        fastcgi_param PATH_INFO       $fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~* ^/(css|img|js|flv|swf|download)/(.+)$ {
        root $root_path;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

mkdir -p /usr/share/nginx/www/dev.mysite.com





