#!/bin/bash

USER_NAME=$1
VM_INDEX=$2
AVAILABILITY_ZONE=$3
ZOOKEEPER_INSTANCES=$4
KAFKA_INSTANCES=$5
IP_PREFIX=$6

yum -y install java-1.8.0-openjdk
yum -y install wget

mkdir -p /var/lib/zookeeper
cd /var/lib/zookeeper

wget https://archive.apache.org/dist/kafka/2.0.0/kafka_2.12-2.0.0.tgz
tar -xzf kafka_2.12-2.0.0.tgz
rm -f kafka_2.12-2.0.0.tgz 

echo 'export PATH=$PATH:/var/lib/zookeeper/kafka_2.12-2.0.0/bin' >>~/.bash_profile
echo "/var/lib/zookeeper/kafka_2.12-2.0.0/bin/zookeeper-server-start.sh /var/lib/zookeeper/kafka_2.12-2.0.0/config/zookeeper.properties> /dev/null 2>&1 &" >>/etc/rc.d/rc.local

chmod +x /etc/rc.d/rc.local
systemctl enable rc-local
systemctl start rc-local
