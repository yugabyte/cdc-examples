# Debezium Embedded Engine App using Logical Replication (YugabyteDBConnector)

This repository contains a Java App that uses [Debezium Engine](https://debezium.io/documentation/reference/stable/development/engine.html) and [YugabyteDB connector](https://github.com/yugabyte/debezium) to stream change records from Yugabyte DB and print them using logical replication protocol.

## Running the App

Here are the steps to run this app

1. Start YugabyteDB
    ```sh
    ./bin/yugabyted start --advertise_address <Your-IP>
    ```
2.  Create a table
    ```sql
    CREATE TABLE test_table (id int primary key, name text);
    ```
3. Create a publication
    ```sql
    CREATE PUBLICATION pub FOR TABLE test_table;
    ```
4. Create a replication slot
    ```sql
    select pg_create_logical_replication_slot('test_slot', 'yboutput');
    ```
5. Compile the Java app
    ```sh
    mvn clean package -Dquick
    ```
    This will fetch the `dz.2.5.2.yb.2025.1.2` version of YugabyteDB connector from Yugabyte's s3 hosted maven. Ensure that your aws credentials are updated before compiling.

    If you do not have access to the said s3 credentials, you can download the YugabyteDB Connector jar from the [releases](https://github.com/yugabyte/debezium/releases) page and run the mvn install command. For simplicity you can run the `download-connector.sh` script which will do this for you.
    ```sh
    chmod +x download-connector.sh
    ./download-connector.sh
    ```

5. Run the jar that has been created
    ```sh
    java -jar target/dbz-embedded-yb-pg-app.jar -slot_name "test_slot" -publication_name "pub" -plugin_name "yboutput" -hostname "<ip>:5433" -port "5433" -database_name "yugabyte" -database_user "<user>" -database_password "****" -topic_prefix "dbserver1"
    ```
> **Note:**
> Currently only following config properties are accepted via command line: slot_name, publication_name, plugin_name, hostname, port, database_name, database_user, database_password and topic_prefix.

6. Now you can perform operations on your table in YugabyteDB and resulting change records will be printed on the console by the app.
