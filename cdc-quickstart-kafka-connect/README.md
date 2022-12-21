# YugabyteDB CDC Pipeline

This repository contains simple steps to set up a YugabyteDB CDC pipeline to get the data from YSQL to a Kafka topic

## Running the CDC pipeline
The following example uses a PostgreSQL database as the sink database, which will be populated using a JDBC Sink Connector.

1. Start YugabyteDB
  This can be a local instance as well as a universe running on Yugabyte Anywhere. All you need is the IP of the nodes where the tserver and master processes are running.
  ```sh
  export NODE=<IP-OF-YOUR-NODE>
  export MASTERS=<MASTER-ADDRESSES>
  ```
2. Create a table
  ```sql
  CREATE TABLE employee (id INT PRIMARY KEY, first_name TEXT, last_name TEXT, dept_id SMALLINT);
  ```
3. Create a stream ID using yb-admin
  ```
  ./yb-admin --master_addresses $MASTERS create_change_data_stream ysql.<namespace>
  ```
4. Start the docker containers
  ```sh
  docker-compose up
  ```
5. Deploy the source connector:
  ```sh
  curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "ybconnector",
    "config": {
      "tasks.max":"1",
      "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
      "database.hostname":"'$NODE'",
      "database.master.addresses":"'$MASTERS'",
      "database.port":"5433",
      "database.user": "yugabyte",
      "database.password":"yugabyte",
      "database.dbname":"yugabyte",
      "database.server.name":"dbserver1",
      "snapshot.mode":"never",
      "database.streamid":"4a585fa40740459e907ff7fd67497869",
      "table.include.list":"public.employee"
    }
  }'
  ```
  **Note: Change the parameters according to the scenario you're working on.**
6. Deploy the sink connector
  ```sh
  curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d @jdbc-sink-pg.json
  ```
7. To login to the PostgreSQL terminal, use:
  ```sh
  docker run --network=yb-cdc-demo_default -it --rm --name postgresqlterm --link pg:postgresql --rm postgres:11.2 sh -c 'PGPASSWORD=postgres exec psql -h pg -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
  ```
8. You can start performing operations on the source now and see them getting replicated in the PostgreSQL table.

## Adding your own connector to the image

If you want to use your own custom connector to the docker image, be ready with the jar file which has all the files required for the connector and follow the given steps:

1. Create a directory
  ```sh
  mkdir ~/custom-image
  ```
2. Copy the jar file to the directory
  ```sh
  cp jarFileXYZ.jar ~/custom-image/
  ```
3. Navigate to the directory and create a Dockerfile
  ```sh
  cd ~/custom-image && touch Dockerfile
  ```
4. Edit the contents of the Dockerfile
  ```Dockerfile
  FROM quay.io/yugabyte/debezium-connector:latest

  COPY jarFileXYZ.jar $KAFKA_CONNECT_PLUGINS_DIR/debezium-connector-yugabytedb/
  ```
5. Build your docker image
  ```sh
  docker build . -t my-custom-image
  ```
  **NOTE: Do not forget to edit the docker-compose file with this custom image name in case you want to use this newly created image with the docker compose commands**

## Monitoring Metrics

The docker compose command will bring up the containers for Prometheus and Grafana. Prometheus is accessible at port ```9090``` and Grafana is accessible at port ```3000```.

  **NOTE: To get metrics for multi-node clusters, you will have to add jobs corresponding to each node in the file** ```prometheus.yml```


## Troubleshooting

* __Unable to write to volumes.__

  If your broker or zookeeper is unable to write to the volumes and gives error like
  `Command [/usr/local/bin/dub path /var/lib/kafka/data writable] FAILED !`,
  then make sure that the volumes directory are owned by your user and not by the `root`. To change the ownership you can run
  ```
    chown -R <user-name>:<user-name> kafka-data
    chown -R <user-name>:<user-name> zookeeper/zookeeper_data
    chown -R <user-name>:<user-name> zookeeper/zookeeper_log
  ```

* __ID mismatch in zookeeper and broker__

  If you get an error saying _broker is trying to join the wrong cluster_ or _the cluster ID does not match stored cluster ID_
  then, delete the contents stored in volumes and restart the containers.
  ```
    rm -rf kafka-data/*
    rm -rf zookeeper/zookeeper_data/*
    rm -rf zookeeper/zookeeper_log/*
  ```