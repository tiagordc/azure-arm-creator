#!/bin/bash

cd $HOME

VM_INDEX=$1
AVAILABILITY_ZONE=$2
ZOOKEEPER_INSTANCES=$3
KAFKA_INSTANCES=$4
IP_PREFIX=$5

sudo yum -y install java-1.8.0-openjdk
sudo yum -y install wget

wget https://archive.apache.org/dist/kafka/2.0.0/kafka_2.12-2.0.0.tgz
tar -xzf kafka_2.12-2.0.0.tgz
rm -f kafka_2.12-2.0.0.tgz 

echo 'export PATH=$PATH:$HOME/kafka_2.12-2.0.0/bin' >>~/.bash_profile
sed -r -i "s/(broker.id)=(.*)/\1=${VM_INDEX}/g" $HOME/kafka_2.12-2.0.0/config/server.properties
