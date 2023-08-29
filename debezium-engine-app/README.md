# Java App to Get Change Records From YugabyteDB using Debezium Engine

This repository contains a Java App that uses [Debezium Engine](https://debezium.io/documentation/reference/stable/development/engine.html) and [YugabyteDB connector](https://github.com/yugabyte/debezium-connector-yugabytedb/tree/main) to stream change records from Yugabyte DB and print them.

## Running the App

Here are the steps to run this app

1. Start YugabyteDB
    ```
    ./bin/yugabyted start --advertise_address <Your-IP> --ui false
    ```
2.  Create a table
    ```
    CREATE TABLE test (id int primary key, name text);
    ```
3. Create a stream ID using yb-admin
    ```
    ./yb-admin --master_addresses <Your-IP> create_change_data_stream ysql.<namespace>
    ```
4. Compile the Java app
    ```
    mvn clean package -Dquick
    ```
5. Run the jar that has been created
    ```
    java -jar target/dbz-embedded-yb-app.jar -master_addresses <Your-IP>:7100 -stream_id <Stream_ID> -table_include_list public.test
    ```
> **Note:**
> Currently only three config properties (i.e. master_addresses, stream_id and table_include_list) are accepted via Command Line. If needed more configs can be added like [this](https://github.com/Sumukh-Phalgaonkar/dbz-embedded-yb-app/blob/main/src/main/java/com/dbzapp/CmdLineOpts.java#L65)

6. Now you can perform operations on your table in YugabyteDB and resulting change records will be printed by the app.
