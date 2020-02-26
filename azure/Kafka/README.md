# Kafka cluster with Bastion

Dynamic Kafka cluster setup with Zookeeper Ensemble.

Azure Bastion for remote VM management using SSH.

# Test setup

SSH to one Kafka node and run:

```sh
/var/lib/kafka/bin/zookeeper-shell.sh 10.0.0.10:2181 ls /brokers/ids
/var/lib/kafka/bin/kafka-topics.sh --create --zookeeper 10.0.0.10:2181 --replication-factor 3 --partitions 3 --topic test
/var/lib/kafka/bin/kafka-topics.sh --list --zookeeper 10.0.0.10:2181
/var/lib/kafka/bin/kafka-console-producer.sh --broker-list 10.0.0.11:9092 --topic test
/var/lib/kafka/bin/kafka-console-consumer.sh --bootstrap-server 10.0.0.11:9092 --topic test --from-beginning
```

# TODO

 * Update Kafka to the latest version

# Resources

Existing ARM Templates:
https://github.com/Azure/azure-quickstart-templates/tree/master/kafka-on-ubuntu

Kafka Setup Tutorials:
https://www.learningjournal.guru/article/kafka/installing-multi-node-kafka-cluster/
https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-centos-7

Other:
https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions
https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux
http://linuxcommand.org/lc3_writing_shell_scripts.php#contents
