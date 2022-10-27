# Multi Node CDC Pipeline

cdc-quickstart-kafka-connect installs all containers in the same VM. 
This examples sets up the CDC Pipeline on different machines. The components of
the CDC Pipeline are:
* Kafka Connect that runs connectors to YugabyteDB and Postgres
* Kafka
* Postgres

## Setup Kafka

### Data in mounted volumes.

Apache Kafka and Zookeeper store data in mounted volumes. External volumes
are recommended when testing at scale. The volumes are stored at 
`$PWD/volumes/kafka/`. The directories are automatically created by docker.
However the owner has to specified as an environment variable - **USERID**.

### Accept External Connections

By default, the Kafka container only accepts connections from the docker
network. The spec file also sets configuration to listen on the machine's
IP address. The IP address is specified in an environment variable -
**KAFKA_HOST**.

### Steps

    export USERID=`id -u`
    export KAFKA_HOST="`hostname -I | awk '{print $1}'`:19092"

    mkdir -p volumes/kafka/kafka-data
    mkdir -p volumes/kafka/zk-data

    docker compose -f confluent.yaml up -d

## Setup Kafka Connect and Postgres

Kafka Connect and Postgres container can be setup in a different VM/machine

    docker compose -f kafka-connect-pg.yaml up -d

    export TABLES="public.employee"
    ./pg-connect.sh
