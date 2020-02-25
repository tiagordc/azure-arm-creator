#!/bin/bash

su $1

cd $HOME

VM_INDEX=$2
AVAILABILITY_ZONE=$3
ZOOKEEPER_INSTANCES=$4
KAFKA_INSTANCES=$5
IP_PREFIX=$6

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
