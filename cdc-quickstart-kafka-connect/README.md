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
    This example uses the [Retail Analytics](https://docs.yugabyte.com/preview/sample-data/retail-analytics/) dataset provided by Yugabyte. All the SQL scripts are also copied in this repository for the ease of use, to create the tables in the dataset, use the file 
  
    ```sql
    \i scripts/schema.sql
    ```
  
3. Create a stream ID using yb-admin
    ```
    ./yb-admin --master_addresses $MASTERS create_change_data_stream ysql.<namespace>
    ```
  
4. Start the docker containers

    ```sh
    docker-compose up -d
    ```
  
5. Deploy the source connector:

    ```sh
    ./deploy-sources.sh <stream-id-created-in-step-3>
    ```
  
6. Deploy the sink connector
    ```sh
    ./deploy-sinks.sh
    ```
  
7. To login to the PostgreSQL terminal, use:
    ```sh
    docker run --network=yb-cdc-demo_default -it --rm --name postgresqlterm --link pg:postgresql --rm postgres:11.2 sh -c 'PGPASSWORD=postgres exec psql -h pg -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
    ```
  
8. To perform operations and insert data to the created tables, you can use other scripts bundled under scripts/
    ```sql
    \i scripts/products.sql;
    \i scripts/users.sql;
    \i scripts/orders.sql;
    \i scripts/reviews.sql;
    ```

### Confluent Control Center

The Confluent Control Center UI is also bundled as part of this example and once everything is running, it can be used to monitor the topics and the connect clusters, etc. The UI will be accessible at http://localhost:9021

### Grafana

You can also access grafana to view the metrics related to CDC and connectors, the dashboard is available at http://localhost:3000

Use the username as `admin` and password as `admin` to login to the console.

**Tip:** Use the `Kafka Connect Metrics Dashboard` to view the basic consolidated metrics at one place. You can start navigating around other dashboards if you need any particular metric.

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
  
 Kafka Connect Metrics Dashboard has all the basic metrics arranged in corresponding pannels. Here are some of the screenshots of this dashboard:
 
 * ![](https://github.com/yugabyte/cdc-examples/blob/main/cdc-quickstart-kafka-connect/screenshots/1%20.png)
 * ![](https://github.com/yugabyte/cdc-examples/blob/main/cdc-quickstart-kafka-connect/screenshots/2.png)
 * ![](https://github.com/yugabyte/cdc-examples/blob/main/cdc-quickstart-kafka-connect/screenshots/3.png)
 * ![](https://github.com/yugabyte/cdc-examples/blob/main/cdc-quickstart-kafka-connect/screenshots/4.png)
 * ![](https://github.com/yugabyte/cdc-examples/blob/main/cdc-quickstart-kafka-connect/screenshots/5.png)
 * ![](https://github.com/yugabyte/cdc-examples/blob/main/cdc-quickstart-kafka-connect/screenshots/6.png)
 * ![](https://github.com/yugabyte/cdc-examples/blob/main/cdc-quickstart-kafka-connect/screenshots/7.png)

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

* __Unable to deploy connectors locally__

  If the command to deploy source connectors (`./deploy-sources.sh <stream-id-created-in-step-3>`) is failing, given you're using docker on MacOS and trying to connect to yugabyteDB instance that is deployed on your local network, it is happening probably because your docker containers are unable to access your local network. You can install something like [docker-mac-net-connect](https://github.com/chipmk/docker-mac-net-connect) to fix this issue.

  ```
    brew install chipmk/tap/docker-mac-net-connect
    sudo brew services start chipmk/tap/docker-mac-net-connect
  ```
