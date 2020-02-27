#!/bin/bash

ORCHESTRATPR_IP=$1
QUERY=$2
LANGUAGE=$3
MODEL_ADDRESS=$4
INSTANCES=$6

apt update
apt-get install -y software-properties-common curl wget

# Setup Redis
apt install -y redis-server
sed -i -E 's/^supervised no/supervised systemd/' /etc/redis/redis.conf
sed -i -E 's/^bind 127.0.0.1/#bind 127.0.0.1/' /etc/redis/redis.conf
systemctl restart redis
netstat -lnp | grep redis

# Setup FTP
apt install -y vsftpd ftp
mkdir /var/ftp/
chmod 555 /var/ftp/
chown ftp.ftp /var/ftp/
sed -i -E 's/^anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
sed -i -E 's/^#anon_upload_enable=YES/anon_upload_enable=YES/' /etc/vsftpd.conf
echo 'anon_root=/var/ftp' >> /etc/vsftpd.conf
echo 'no_anon_password=YES' >> /etc/vsftpd.conf
echo 'anon_other_write_enable=YES' >> /etc/vsftpd.conf
echo 'anon_mkdir_write_enable=YES' >> /etc/vsftpd.conf
echo 'userlist_file=/etc/vsftpd.userlist' >> /etc/vsftpd.conf
echo 'userlist_enable=YES' >> /etc/vsftpd.conf
echo 'userlist_deny=NO' >> /etc/vsftpd.conf
echo 'anonymous' > /etc/vsftpd.userlist
systemctl restart vsftpd
netstat -ant | grep 21

# Get and build project
apt-get install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
apt-get install -y nodejs git
mkdir /var/lib/scrapper
cd /var/lib/scrapper
git clone https://github.com/tiagordc/web-image-scrapper.git .
npm install --unsafe-perm=true --allow-root

# Run
# node /var/lib/scrapper/index.js -o localhost -q $QUERY -l $LANGUAGE -m $MODEL_ADDRESS --seed
