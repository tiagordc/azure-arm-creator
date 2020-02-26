#!/bin/bash

USER_NAME=$1
VM_INDEX=$2
AVAILABILITY_ZONE=$3
ZOOKEEPER_INSTANCES=$4
KAFKA_INSTANCES=$5
IP_PREFIX=$6

yum -y install java-1.8.0-openjdk
yum -y install wget

cd /usr/local

wget https://archive.apache.org/dist/kafka/2.0.0/kafka_2.12-2.0.0.tgz
tar -xzf kafka_2.12-2.0.0.tgz
rm -f kafka_2.12-2.0.0.tgz 

echo 'export PATH=$PATH:/usr/local/kafka_2.12-2.0.0/bin' >>~/.bash_profile

cd kafka_2.12-2.0.0/config

sed -r -i "s/(broker.id)=(.*)/\1=${VM_INDEX}/g" server.properties
LINE_NUMBER=`grep -nr 'broker.id=' server.properties | cut -d : -f 1`
LINE_NUMBER=$(( $LINE_NUMBER + 1 ))
sed -i "${LINE_NUMBER} i broker.rack=ZONE${AVAILABILITY_ZONE}" server.properties
sed -r -i "s/(offsets.topic.replication.factor)=(.*)/\1=2/g" server.properties
LINE_NUMBER=`grep -nr 'offsets.topic.replication.factor=' server.properties | cut -d : -f 1`
sed -i "${LINE_NUMBER} i offsets.topic.num.partitions=3" server.properties
LINE_NUMBER=$(( $LINE_NUMBER + 4 ))
sed -i "${LINE_NUMBER} i default.replication.factor=2" server.properties
sed -i "${LINE_NUMBER} i min.insync.replicas=2" server.properties

ZOOKEEPER=""
for (( c=0; c<$ZOOKEEPER_INSTANCES; c++ ))
do
    if [ "$ZOOKEEPER" != "" ]; then
        ZOOKEEPER=$ZOOKEEPER","
    fi
    CURRENT=$(( $c + 10 ))
    ZOOKEEPER=$ZOOKEEPER$IP_PREFIX$CURRENT":2181"
done
sed -r -i "s/(zookeeper.connect)=(.*)/\1=${ZOOKEEPER}/g" server.properties

echo "/usr/local/kafka_2.12-2.0.0/bin/kafka-server-start.sh /usr/local/kafka_2.12-2.0.0/config/server.properties> /dev/null 2>&1 &" >>/etc/rc.d/rc.local

chmod +x /etc/rc.d/rc.local
systemctl enable rc-local
systemctl start rc-local
