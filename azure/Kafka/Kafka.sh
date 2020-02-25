#!/bin/bash

cd $HOME

VM_INDEX=$1
AVAILABILITY_ZONE=$2
ZOOKEEPER_INSTANCES=$3
KAFKA_INSTANCES=$4
IP_PREFIX=$5

PROPS="$HOME/kafka_2.12-2.0.0/config/server.properties"

sudo yum -y install java-1.8.0-openjdk
sudo yum -y install wget

wget https://archive.apache.org/dist/kafka/2.0.0/kafka_2.12-2.0.0.tgz
tar -xzf kafka_2.12-2.0.0.tgz
rm -f kafka_2.12-2.0.0.tgz 

echo 'export PATH=$PATH:$HOME/kafka_2.12-2.0.0/bin' >>~/.bash_profile
sed -r -i "s/(broker.id)=(.*)/\1=${VM_INDEX}/g" $PROPS

LINE_NUMBER=`grep -nr 'broker.id=' $PROPS | cut -d : -f 1`
LINE_NUMBER=$(( $LINE_NUMBER + 1 ))
sed -i "${LINE_NUMBER} i broker.rack=ZONE${AVAILABILITY_ZONE}" $PROPS
sed -r -i "s/(offsets.topic.replication.factor)=(.*)/\1=2/g" $PROPS
LINE_NUMBER=`grep -nr 'offsets.topic.replication.factor=' $PROPS | cut -d : -f 1`
sed -i "${LINE_NUMBER} i offsets.topic.num.partitions=3" $PROPS
LINE_NUMBER=$(( $LINE_NUMBER + 4 ))
sed -i "${LINE_NUMBER} i default.replication.factor=2" $PROPS
sed -i "${LINE_NUMBER} i min.insync.replicas=2" $PROPS

ZOOKEEPER=""
for (( c=0; c<$ZOOKEEPER_INSTANCES; c++ ))
do
    if [ "$ZOOKEEPER" != "" ]; then
        ZOOKEEPER=$ZOOKEEPER","
    fi
    CURRENT=$(( $c + 10 ))
    ZOOKEEPER=$ZOOKEEPER$IP_PREFIX$CURRENT":2181"
done
sed -r -i "s/(zookeeper.connect)=(.*)/\1=${ZOOKEEPER}/g" $PROPS

echo "$HOME/kafka_2.12-2.0.0/bin/kafka-server-start.sh $PROPS> /dev/null 2>&1 &" >>/etc/rc.d/rc.local

sudo chmod +x /etc/rc.d/rc.local
sudo systemctl enable rc-local
sudo systemctl start rc-local
