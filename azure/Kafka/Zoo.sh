#!/bin/bash

cd $HOME

sudo yum -y install java-1.8.0-openjdk
sudo yum -y install wget

wget https://archive.apache.org/dist/kafka/2.0.0/kafka_2.12-2.0.0.tgz
tar -xzf kafka_2.12-2.0.0.tgz
rm -f kafka_2.12-2.0.0.tgz 

echo 'export PATH=$PATH:$HOME/kafka_2.12-2.0.0/bin' >>~/.bash_profile
echo "$HOME/kafka_2.12-2.0.0/bin/zookeeper-server-start.sh $HOME/kafka_2.12-2.0.0/config/zookeeper.properties> /dev/null 2>&1 &" >>/etc/rc.d/rc.local

sudo chmod +x /etc/rc.d/rc.local
sudo systemctl enable rc-local
sudo systemctl start rc-local
