# Authentication & Authorization

This repository contains simple steps to set up a YugabyteDB CDC pipeline with a kafka cluster that has authentication and authorization enabled.

## Setup

### Configuring kafka cluster
Kafka supports [multiple](https://docs.confluent.io/platform/current/kafka/overview-authentication-methods.html#authentication-methods-overview) mechanisms and protocols for authentication. However, in this example we'll be configuring our kafka cluster to use [SASL/PLAIN](https://docs.confluent.io/platform/current/kafka/authentication_sasl/authentication_sasl_plain.html#configuring-plain) as an authentication mechanism. `SASL/PLAIN` uses a simple username and password for authentication.

Kafka uses the Java Authentication and Authorization Service (JAAS) for SASL configuration. We need to provide JAAS configurations for all SASL authentication mechanisms. We'll create four users i.e. `admin`, `connect_wokrer`, `source_connector` and `sink_connector`. The JAAS configuration would look something like.

```
KafkaServer {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="admin-secret"
  user_admin="admin-secret"
  user_connect_worker="connect-secret"
  user_source_connector="source-secret"
  user_sink_connector="sink-secret";
};
```

Also, we need to configure the `broker` to use the above configuration for authentication.

```yaml
broker:
  image: confluentinc/cp-server:7.2.1
  ...
  environment:
    ...
    KAFKA_ADVERTISED_LISTENERS: "SASL_PLAINTEXT://localhost:9092"
    KAFKA_INTER_BROKER_LISTENER_NAME: SASL_PLAINTEXT
    KAFKA_SASL_ENABLED_MECHANISMS: PLAIN
    KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL: PLAIN
    KAFKA_OPTS: "-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf"
  volumes:
    ...
    - ./kafka_server_jaas.conf:/etc/kafka/kafka_server_jaas.conf
```

Now, we need to configure authorization in the cluster. Again, kafka supports multiple methods for authorization like [RBAC](https://docs.confluent.io/platform/current/security/rbac/index.html), [ACLs](https://docs.confluent.io/platform/current/security/rbac/authorization-acl-with-mds.html) and [LDAP](https://docs.confluent.io/platform/current/security/csa-introduction.html#configuring-csa). We'll be using `ACLs` for authorization in this example.

To use ACLs we need to add the following properties to `broker` configuration.

```yaml
broker:
  image: confluentinc/cp-server:7.2.1
  ...
  environment:
    ...
    KAFKA_AUTHORIZER_CLASS_NAME: kafka.security.authorizer.AclAuthorizer
    KAFKA_SUPER_USERS: User:admin
```

This will also give super user permissions to the user `admin`.

### Giving required permissions to users
We'll be using `kafka-acls` CLI to specify acl rules in our cluster.

User `connect_worker` will be used by the debezium connect worker. It needs access to the resources mentioned [here](https://docs.confluent.io/platform/current/connect/security.html#worker-acl-requirements).

If you're using the examples in this repository. You can use the following commands to give the required permissions to the user `connect_worker`.

```bash
./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:connect_worker --operation ALL --topic 'kafka-connect' --resource-pattern-type 'PREFIXED'
./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:connect_worker --operation 'Read' --group '1'
```

Users `source_connector` and `sink_connector` will be used by the source and sink connectors respectively. These users need access to the resources mentioned [here](https://docs.confluent.io/platform/current/connect/security.html#connector-acl-requirements).

If you're using the examples in this repository. You can use the following commands to give the required permissions.

Note: You need to give `Create` permissions to sink connectors because they'll creating the topic if it doesn't exist already.

```bash
# Source connectors
./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:source_connector --operation 'Write' --operation 'Create' --operation 'Describe' --topic 'ybconnector' --resource-pattern-type 'PREFIXED'

# Sink connectors
./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:sink_connector --operation 'Create' --operation 'Read' --operation 'Describe' --topic 'ybconnector' --resource-pattern-type 'PREFIXED'
./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:sink_connector --operation 'Read' --group 'connect' --resource-pattern-type 'PREFIXED'
```

### Configuring the connect workers and connectors
The authentication mechanism and credentials need to be specified to the debezium connector for it to be able to connect to the kafka cluster. Also, we need to specify the authentication mechanism to be used by the source and sink connectors that will be deployed later on.

```yaml
kafka-connect:
  image: quay.io/yugabyte/debezium-connector:latest
  ...
  environment:
    ...
    CONNECT_SASL_MECHANISM: PLAIN
    CONNECT_SECURITY_PROTOCOL: SASL_PLAINTEXT
    CONNECT_SASL_JAAS_CONFIG: org.apache.kafka.common.security.plain.PlainLoginModule required username="connect_worker" password="connect-secret";
    CONNECT_PRODUCER_SASL_MECHANISM: PLAIN
    CONNECT_PRODUCER_SECURITY_PROTOCOL: SASL_PLAINTEXT
    CONNECT_CONSUMER_SASL_MECHANISM: PLAIN
    CONNECT_CONSUMER_SECURITY_PROTOCOL: SASL_PLAINTEXT
    CONNECT_CONNECTOR_CLIENT_CONFIG_OVERRIDE_POLICY: Principal
```

We can specify the user to be used by individual connectors in their config by overriding the values we provided above.


```json
{
  "name": "ybconnector1",
  "config": {
    ...,
    "producer.override.sasl.jaas.config":"org.apache.kafka.common.security.plain.PlainLoginModule required username=\"source_connector\" password=\"source-secret\";"
  }
}
```

## Example
In the following example, we'll setup cdc with a kafka cluster that has authorization and authentication enabled.

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

5. Give the required permissions to each user
    ```sh
    # connect_worker
    ./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:connect_worker --operation ALL --topic 'kafka-connect' --resource-pattern-type 'PREFIXED'
    ./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:connect_worker --operation 'Read' --group '1'

    # source_connector
    ./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:source_connector --operation 'Write' --operation 'Create' --operation 'Describe' --topic 'ybconnector' --resource-pattern-type 'PREFIXED'

    # sink_connector
    ./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:sink_connector --operation 'Create' --operation 'Read' --operation 'Describe' --topic 'ybconnector' --resource-pattern-type 'PREFIXED'
    ./bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./admin.properties --add --allow-principal User:sink_connector --operation 'Read' --group 'connect' --resource-pattern-type 'PREFIXED'
    ```

5. Deploy the source connectors

    ```sh
    ./deploy-sources.sh <stream-id-created-in-step-3>
    ```

6. Deploy the sink connectors
    ```sh
    ./deploy-sinks.sh
    ```

7. To login to the PostgreSQL terminal, use:
    ```sh
    docker run --network=authorization_default -it --rm --name postgresqlterm --link pg:postgresql --rm postgres:11.2 sh -c 'PGPASSWORD=postgres exec psql -h pg -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
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
