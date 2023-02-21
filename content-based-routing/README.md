# Content Based Routing

This repository contains simple steps to set up a YugabyteDB CDC pipeline and deploy a connector with content based routing configured.

## Running the CDC pipeline
In following example, we will create a table called `products` and route all the `create` events from this table to a different kafka topic `create_events`. Other events from this table will still be present in the `ybconnector.public.products` topic.

1. Start YugabyteDB
    This can be a local instance as well as a universe running on Yugabyte Anywhere. All you need is the IP of the nodes where the tserver and master processes are running.
    ```sh
    export NODE=<IP-OF-YOUR-NODE>
    export MASTERS=<MASTER-ADDRESSES>
    ```
  
2. Create a table
    This example uses the `products` table of the [Retail Analytics](https://docs.yugabyte.com/preview/sample-data/retail-analytics/) dataset provided by Yugabyte. All the SQL scripts are also copied in this repository for the ease of use, to create the tables in the dataset, use the file 
  
    ```sql
    \i scripts/schema.sql
    ```
  
3. Create a stream ID using yb-admin
    ```
    ./yb-admin --master_addresses $MASTERS create_change_data_stream ysql.<namespace>
    ```

4. Build the yugabyte-debezium docker image with all the required plugins
    ```sh
    docker build . -t yugabyte-debezium-connector-cbr
    ```
  
5. Start the docker containers

    ```sh
    docker-compose up -d
    ```
  
6. Deploy the connector:

    ```sh
    ./deploy-connector.sh <stream-id-created-in-step-3>
    ```
  
7. Perform SQL operations and insert data to the created table
    To insert sample data to the table, you can use the following script.
    ```sql
    \i scripts/products.sql;
    ```

### Confluent Control Center

The Confluent Control Center UI is also bundled as part of this example and once everything is running, it can be used to monitor the topics and the connect clusters, etc. The UI will be accessible at http://localhost:9021
