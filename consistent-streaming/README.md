# YugabyteDB CDC Consistent Streaming Pipeline

This repository contains simple steps to set up a YugabyteDB CDC consistent streaming pipeline to get the data from YSQL to a Kafka topic

## Running the CDC pipeline
The following example uses a PostgreSQL database as the sink database, which will be populated using JDBC Sink Connector.

1. Start YugabyteDB
    This can be a local instance as well as a universe running on Yugabyte Anywhere. All you need is the IP of the nodes where the tserver and master processes are running.
    ```sh
    export NODE=<IP-OF-YOUR-NODE>
    export MASTERS=<MASTER-ADDRESSES>
    ```
  
2. Create a table
    This example uses two tables having a foreign key constraint. However, you can start with any tables of your choice.
  
    ```sql
    CREATE TABLE department (id INT PRIMARY KEY, dept_name TEXT);
    CREATE TABLE employee (id INT PRIMARY KEY, emp_name TEXT, d_id INT, FOREIGN KEY (d_id) REFERENCES department(id));
    ```
  
3. Create a stream ID using yb-admin
    ```
    ./yb-admin --master_addresses $MASTERS create_change_data_stream ysql.<namespace> EXPLICIT
    ```

    **Note:** To use consistent streaming, you will need to create the stream in explicit checkpointing mode only.
  
4. Start the docker containers

    ```sh
    docker-compose up -d
    ```
  
5. Deploy the source connector:

    ```sh
    ./deploy-sources.sh <stream-id-created-in-step-3> <comma-separated-list-of-tables>
    ```

    For example:
    ```sh
    ./deploy-sources.sh 65a857d957f34507aa4fd97ebcb6ff56 public.department,public.employee
    ```

    #### Key considerations

    This example has the source connector configuration where we are using a transformer to route all the messages to a common topic i.e. by using the [ByLogicalTableRouter](https://debezium.io/documentation/reference/stable/transformations/topic-routing.html) - this is required in order to make sure that while reading the records, the sink connectors have only a single source of data, otherwise it would be very complicated to maintain records in a consistent order.

    We also publish the transaction metadata to this common topic where all the records are being routed, this metadata consists of `BEGIN` and `END` records marking the status of a transaction.

    Additionally, the following configuration properties are of key importance while deploying the source connector:

    | Config property | Default | Description |
    | :--- | :--- | :--- |
    | `provide.transaction.metadata` | `false` | Send metadata related to transaction boundaries |
    | `transaction.ordering` | `false` | Whether to sort transactions in connector |
  
6. Deploy the sink connector
    
    ```sh
    ./deploy-sinks.sh $NODE
    ```

    #### Key considerations
    To aide the streaming of the records transactionally and atomically, we've made some changes to the way the sink connector reads and inserts records in the target database. As mentioned above, we also publish the transaction metadata to the topic i.e. `BEGIN` and `END` records, so now as soon as the connector reads a `BEGIN` record, it starts to aggregate records until it sees a `END` record, once it reads an `END` record, it executes all the aggregated records in a single transaction, thus maintaining atomicity. The following sink configuration parameters have been added:

    | Config property | Default | Description |
    | :--- | :--- | :--- |
    | `consistent.writes` | `false` | Whether to write transactionally and atomically |
    | `table.identifier.field` (Optional) | `__dbz_physicalTableIdentifier` | The extra field added by the transformer `ByLogicalTableRouter` |
    | `remove.table.identifier.field` (Optional) | `true` | Whether to remove the table identifier field |
  
7. To login to the PostgreSQL terminal, use:
    
    ```sh
    docker run --network=cdc-quickstart-kafka-connect_default -it --rm --name postgresqlterm --link pg:postgresql --rm postgres:11.2 sh -c 'PGPASSWORD=postgres exec psql -h pg -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
    ```
  
8. Create target tables. It is recommended to create target tables with the required constraints and not rely on auto creation in case of consistent streaming.
    
    ```sql
    CREATE TABLE department (id INT PRIMARY KEY, dept_name TEXT);
    CREATE TABLE employee (id INT PRIMARY KEY, emp_name TEXT, d_id INT, FOREIGN KEY (d_id) REFERENCES department(id));
    ```

9. Insert records into the table now.

    ```sql
    INSERT INTO department VALUES (generate_series(1,10), 'department_name');
    INSERT INTO employee VALUES (generate_series(11, 20), 'employee_name', generate_series(1,10));
    ```

### Confluent Control Center

The Confluent Control Center UI is also bundled as part of this example and once everything is running, it can be used to monitor the topics and the connect clusters, etc. The UI will be accessible at http://localhost:9021

### Grafana

You can also access grafana to view the metrics related to CDC and connectors, the dashboard is available at http://localhost:3000

Use the username as `admin` and password as `admin` to login to the console.

**Tip:** Use the `Kafka Connect Metrics Dashboard` to view the basic consolidated metrics at one place. You can start navigating around other dashboards if you need any particular metric.
