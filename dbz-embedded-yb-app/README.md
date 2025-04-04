# Debezium Embedded Engine Application YugabyteDB

An application demonstrating the usage of Debezium Engine with the Debezium Connector for YugabyteDB.

## Building the application

Run the following maven command to build the jar file:

```sh
mvn clean package -Dquick
```

## Running the executable jar

Once you have built the jar file, it will be available under the `target/` directory with the name `dbz-embedded-yb-app.jar`. The jar file accepts the following parameters:
* `-master_addresses` - the address of the master processes in the form host:port
* `-stream_id` - the DB stream ID to use while initializing the engine
* `-table_include_list` - the list of tables to poll for in the form `<schemaName>.<tableName>`

The following parameters have the default values and cannot be changed as of now:
| Parameter | Default value |
| :--- | :--- |
| `database.user` | yugabyte |
| `database.password` | yugabyte |
| `database.dbname` | yugabyte |
| `database.hostname` | IP of the first node provided<br>in the master addresses |
| `database.port` | 5433 |
| `snapshot.mode` | never |

To run the jar file, use the command:

```sh
java -jar target/dbz-embedded-yb-app.jar -master_addresses <master-addresses> -stream_id <stream-id> -table_include_list <table-include-list>
```