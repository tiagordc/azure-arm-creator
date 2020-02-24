#!/bin/bash

cd $HOME

sudo yum -y install java-1.8.0-openjdk
sudo yum -y install wget

wget https://archive.apache.org/dist/kafka/2.0.0/kafka_2.12-2.0.0.tgz
tar -xzf kafka_2.12-2.0.0.tgz
rm -f kafka_2.12-2.0.0.tgz 

echo 'export PATH=$PATH:$HOME/kafka_2.12-2.0.0/bin' >>~/.bash_profile
echo -e "Index: $1\nZone: $2\nZookeper: $3\nKafka: $4\nPrefix: $5" >~/setup.properties
