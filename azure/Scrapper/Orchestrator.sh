
sudo apt update

# Setup Redis
sudo apt install -y redis-server
sudo sed -i -E 's/^supervised no/supervised systemd/' /etc/redis/redis.conf
sudo sed -i -E 's/^bind 127.0.0.1/#bind 127.0.0.1/' /etc/redis/redis.conf
sudo systemctl restart redis
sudo netstat -lnp | grep redis

#Setup FTP
sudo apt install -y vsftpd ftp
sudo mkdir /var/ftp/
sudo chmod 555 /var/ftp/
sudo chown ftp.ftp /var/ftp/
sudo sed -i -E 's/^anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
sudo sed -i -E 's/^#anon_upload_enable=YES/anon_upload_enable=YES/' /etc/vsftpd.conf
sudo echo 'anon_root=/var/ftp' >> /etc/vsftpd.conf
sudo echo 'no_anon_password=YES' >> /etc/vsftpd.conf
sudo echo 'anon_other_write_enable=YES' >> /etc/vsftpd.conf
sudo echo 'anon_mkdir_write_enable=YES' >> /etc/vsftpd.conf
sudo echo 'userlist_file=/etc/vsftpd.userlist' >> /etc/vsftpd.conf
sudo echo 'userlist_enable=YES' >> /etc/vsftpd.conf
sudo echo 'userlist_deny=NO' >> /etc/vsftpd.conf
sudo echo anonymous > /etc/vsftpd.userlist
sudo systemctl restart vsftpd
sudo netstat -ant | grep 21
