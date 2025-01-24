# Multi Node CDC Pipeline

cdc-quickstart-kafka-connect installs all containers in the same VM. 
This examples sets up the CDC Pipeline on different machines. The components of
the CDC Pipeline are:
* YugabyteDB Cluster
* Kafka Connect that runs connectors to YugabyteDB and Postgres
* Kafka
* Postgresql

## TPCC Setup

The example uses TPCC tables. Setup the TPCC benchmark by following the
instructions in [Yugabyte docs](https://docs.yugabyte.com/preview/benchmark/tpcc-ysql/)

    # Create the tables
    ./tpccbenchmark --create=true --nodes=<CSV of YB Cluster IP/Host names>

    # Create a CDC Stream
    # Store YugabyteDB Master IP addresses in an env variable
    export MASTER_ADDRESSES=<list of addresses>

    # Setup CDCSDK Stream
    yb-admin create_change_data_stream ysql.yugabyte --master_addresses $MASTER_ADDRESSES

    # Save the output of the previous command in an env variable.
    export CDC_SDK_STREAM_ID=<id from previous command>


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

## Setup Kafka Connect, Yugabyte and Postgres Connectors

Kafka Connect and Postgres container can be setup in a different VM/machine

    export USERID=`id -u`
    export KAFKA_HOST="<IP of Kafka Machine>:19092"

    docker compose -f kafka-connect-pg.yaml up -d

    export PGHOST=<any host in the YugabyteDB cluster>
    export PGUSER=<Username of role in YugabyteDB>
    export PGPASSWORD=<Password of role in YugabyteDB>
    export PGDATABASE=<Database to connecto to>
    export TOPIC_PREFIX=tpcc

    TABLES="public.customer,public.district,public.item,public.new_order,public.oorder,public.order_line,public.stock,public.warehouse"

    ./yb-connect.sh

    # Note: PSQL prefix is used because PGHOST is also used by Yugabyte scripts.
    export PSQL_HOST=<any host in the YugabyteDB cluster>
    export PSQL_USER=<Username of role in YugabyteDB>
    export PSQL_PWD=<Password of role in YugabyteDB>
    export PSQL_DB=<Database to connecto to>

    ./pg-connect.sh
