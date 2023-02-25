# Content Based Routing

This repository contains simple steps to set up a YugabyteDB CDC pipeline and deploy a connector with content based routing configured.

## What's different from a normal CDC setup?
There are some dependencies that are required for content-based routing to work. These are not included in the official yugabyte-debezium-connector for security reasons. In particular, the following plugins are included in the [Dockerfile](./Dockerfile).

- Debezium routing SMT (Single Message Transform)
- Groovy JSR223 implementation

## Running the CDC pipeline
In following example, we will create a table called `users` and route all the events from users with country `UK` to a different kafka topic `uk_users`. Other events from this table will still be present in the `ybconnector.public.users` topic. An scenario where this example may be helpful is when the system needs to follow GDPR regulations of a country and need to geolocate the data.

1. **Start YugabyteDB**
    This can be a local instance as well as a universe running on Yugabyte Anywhere. All you need is the IP of the nodes where the tserver and master processes are running.
    ```sh
    export NODE=<IP-OF-YOUR-NODE>
    export MASTERS=<MASTER-ADDRESSES>
    ```
  
2. **Create a table**
    We have a sample dataset for this example. To create the `users` table, run the following command.
    ```sql
    \i scripts/schema.sql
    ```
  
3. **Create a stream ID** with before image enabled using yb-admin. This is to ensure we get all the columns in each event.
    ```
    ./yb-admin --master_addresses $MASTERS create_change_data_stream ysql.<namespace> IMPLICIT ALL
    ```

4. **Build the yugabyte-debezium docker image** with all the required plugins
    ```sh
    docker build . -t yugabyte-debezium-connector-cbr
    ```
  
5. **Start the docker containers**

    ```sh
    docker-compose up -d
    ```
  
6. **Deploy the connector**

    ```sh
    ./deploy-connector.sh <stream-id-created-in-step-3>
    ```
  
7. **Perform SQL operations** and insert data to the created table. You should be able to see the events being routed to the `uk_users` kafka topic as expected. 
    To insert sample data to the table, you can use the following script.
    ```sql
    \i scripts/users.sql;
    ```

### Confluent Control Center

The Confluent Control Center UI is also bundled as part of this example and once everything is running, it can be used to monitor the topics and the connect clusters, etc. The UI will be accessible at http://localhost:9021
