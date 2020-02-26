
sudo apt update

sudo apt install -y build-essential curl file git linuxbrew-wrapper vsftpd

brew install redis

sudo sed -r -i "s/(anonymous_enable)=(.*)/\1=YES/g" /etc/vsftpd.conf
#no_anon_password=YES

sudo systemctl enable vsftpd
sudo systemctl start vsftpd

netstat -ant | grep 21
