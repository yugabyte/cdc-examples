# Protobuf Binary Data
[Protocol Buffers](https://protobuf.dev) are Google’s language-neutral, platform-neutral, extensible mechanism for serializing structured data. One of the key features of protocol buffers (or protobuf) is that it can encode the messages to binary format having really small sizes.

This example contains simple steps on how you can leverage the `bytea` field to store the Protobuf binary data and setup a YugabyteDB CDC Connector that streams the changes to a kafka topic.

Also, we'll run a [consumer](./consumer/) that reads the messages from kafka and re-creates the protobuf message using binary data.

## Example
1. Start YugabyteDB
    This can be a local instance as well as a universe running on Yugabyte Anywhere. All you need is the IP of the nodes where the tserver and master processes are running.
    ```sh
    export NODE=<IP-OF-YOUR-NODE>
    export MASTERS=<MASTER-ADDRESSES>
    ```

2. Create a table
    To create the required table for this example, use the file

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

5. Deploy the source connectors

    We have created two connector configurations which use `avro` and `json` as kafka serialization formats respectively.

    To deploy a connector with `avro` serialization, run the following.

    ```sh
    ./deploy-avro.sh <stream-id-created-in-step-3>
    ```

    Alternatively, you choose to deploy a connector with `json` serialization. To do so, run the following.

    ```sh
    ./deploy-json.sh <stream-id-created-in-step-3>
    ```

6. Build and run the consumer

    We have created a [consumer](./consumer/) for demonstration purposes. First we'll need to build it.

    ```sh
    cd consumer && mvn package
    ```

    Now we can run the consumer. You need to specify the serialization format used while deploying the source connector.

    ```sh
    java -jar target/protobuftest-1.0-SNAPSHOT-jar-with-dependencies.jar <avro/json>
    ```

7. Perform operations on the created table

    We've added a utility script that can be used to perform operations on the table we created to test the complete protobuf+cdc setup.

    First, we need to install the required dependencies.

    ```sh
    cd scripts
    pip install -r requirements.txt
    ```

    Now, we can either create/update/delete an entity in the database using the script.

    ```sh
    # Create a new user
    python users.py --create

    # Update an existing entry with new user data
    python users.py --update

    # Delete an user
    python users.py --delete
    ```

    We should be able to see the logs in the consumer microservice (started in step 6) for the changes made in the table.

### Confluent Control Center

The Confluent Control Center UI is also bundled as part of this example and once everything is running, it can be used to monitor the topics and the connect clusters, etc. The UI will be accessible at http://localhost:9021
