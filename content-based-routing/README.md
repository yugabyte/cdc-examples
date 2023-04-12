# Content Based Routing

This repository contains simple steps to set up a YugabyteDB CDC pipeline and deploy a connector with content based routing configured.

## Setup
### Rebuilding the yugabyte-debezium-connector image
There are some dependencies that are required for content-based routing to work. These are not included in the official yugabyte-debezium-connector for security reasons. To be specific, we need the following plugins in our image.

- Debezium routing SMT (Single Message Transform)
- Groovy JSR223 implementation (or GraalVM JavaScript JSR 223 implementation)

You can use the [Dockerfile](./Dockerfile) in this repository to build the connector with all the required plugins.

### Configure the debezium connector
By default, a connector created on the yugabyte’s debezium cdc connector streams all the events from a table in a single kafka topic.

However, you might want to push events to other kafka topics based on the event content. To do that, [ContentBasedRouter](https://debezium.io/documentation/reference/stable/transformations/content-based-routing.html) should be used. For example, in the following configuration all events from a table with a column country set to `UK` will be routed to `uk_users` topic.

```json
"transforms":"route",
"transforms.route.type":"io.debezium.transforms.ContentBasedRouter",
"transforms.route.language":"jsr223.groovy",
"transforms.route.topic.expression":"value.after != null ? (value.after?.country?.value == 'UK' ? 'uk_users' : null) : (value.before?.country?.value == 'UK' ? 'uk_users' : null)",
```

The expression defined in `transforms.route.topic.expression` checks if the value of the row after the operation has the country set to `UK`, if yes, it returns `uk_users` and `null` otherwise. And if there is no value provided for after the operation (For example - In delete operation), we check for value before the operation.

The value returned from this expression decides the new kafka topic where the event will be re-routed to. In case it returns `null`, it is sent to the default topic.

For more advanced routing configuration, you can refer to debezium's official documentation on content based routing [here](https://debezium.io/documentation/reference/stable/transformations/content-based-routing.html).

## Example
In following example, we will create a table called `users` and route all the events from users with country `UK`, `India` and `USA` to different kafka topics. Other events from this table will still be present in the default `ybconnector.public.users` topic. An scenario where this example may be helpful is when the system needs to follow GDPR regulations of a country and need to geolocate the data.

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

7. **Perform SQL operations** and insert data to the created table. You should be able to see the events being routed to the `uk_users`, `india_users` and `usa_users` kafka topics as expected.
    To insert sample data to the table, you can use the following script.
    ```sql
    \i scripts/users.sql;
    ```

### Confluent Control Center

The Confluent Control Center UI is also bundled as part of this example and once everything is running, it can be used to monitor the topics and the connect clusters, etc. The UI will be accessible at http://localhost:9021
