# Running Logical Replication with Confluent images

This example demonstrates, how to create a custom kafka connect image using confluent's kafka connect as the base image to run Yugabyte-DB (logical replication) debezium connector. This is helpful when we need to apply confluent's Simple Message Transforms on the data being streamed.

Here we will first create a confluent based kafka connect docker image and then apply the Confluent's `Filter` and `ReplaceField` SMTs.

## Data Flow Pipeline

The source DB (i.e Yugabyte-DB) will contain a single table with only two columns. The source connector will send the change records to kafka and while sending add a third column `origin_db` to each record. The sink connector will selectively apply those records from kafka with specific values of `origin_db` to the sink DB (in this case, Postgres). In this process we will also remove the artificially added column from the records so that the sink DB has the same schema as the source DB.

This kind of deployment is useful in cases where the kafka topic is being shared between multiple DB's and unchecked replication can lead to cylical movement of change records. Nonetheless the objective of this example is to demonstrate the process of applying Confluent's SMTs while using Yugabyte-DB CDC with logical replication.


## Lets Get Started

1. Start a yugabyted universe:

```sh
<path-to-yugabyted-bin>/yugabyted start --advertise_address <IP-OF-YOUR-MACHINE>
```

2. Log in to ysql shell and create a table:

```sql
CREATE TABLE fruits (id int primary key, name text);
```

3. Create a custom Confluent based kafka connect image:

```sh
cd custom-confluent-image
wget https://github.com/yugabyte/debezium/releases/download/dz.2.5.2.yb.2024.2.5/yugabytedb-source-connector-dz.2.5.2.yb.2024.2.5-jar-with-dependencies.jar
docker build . -t custom-confluent-image
```
Here we will be using the Yugabyte-DB connector version `dz.2.5.2.yb.2024.2.5`. If you want to use any other version, make appropriate changes to the above wget command and the Docker file inside `custom-confluent-image` directory.

4. Start the docker containers

```sh
docker compose up -d
```

5. Deploy the source connector. Remember to change the `database.hostname` field below.

```sh
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "yb-source-connector",
  "config": {
    "tasks.max":"1",
    "connector.class": "io.debezium.connector.postgresql.YugabyteDBConnector",
    "database.hostname":"<IP-OF-YOUR-MACHINE>",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"yugabyte",
    "database.dbname":"yugabyte",
    "topic.prefix":"dbserver1",
    "snapshot.mode":"never",
    "plugin.name":"yboutput",
    "slot.name":"yb_replication_slot",
    "publication.name":"yb_publication",
    "transforms": "unwrap,InsertField",
    "transforms.unwrap.type":"io.debezium.connector.postgresql.transforms.yugabytedb.YBExtractNewRecordState",
    "transforms.unwrap.drop.tombstones":"false",
    "transforms.InsertField.type":"org.apache.kafka.connect.transforms.InsertField$Value",
    "transforms.InsertField.static.field":"origin_db",
    "transforms.InsertField.static.value":"main_table",
    "key.converter":"org.apache.kafka.connect.json.JsonConverter",
    "value.converter":"org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable":"true",
    "value.converter.schemas.enable":"true"
  }
}'
```
Here we are using the InsertField SMT to add the column `origin_db` with value `main_table` to each change record to kafka.

6. Verify that the connector has created the replication slot. This might take some time:

```sql
SELECT * FROM pg_replication_slots;
```

7. Insert a record in the table:

```sql
INSERT INTO fruits values (1, 'Banana');
```

8. Check that the record in kafka has extra column as intended:

You can go to the control center UI by visiting the `<IP-OF-YOUR-MACHINE>:9021` on your browser and check the message in kafka topic. If the messages are not being showed, try searching for message with offset 0.


9. Now lets deploy the sink connector with SMTs to filter the data based on `origin_db` and remove excess information:

```sh
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" \
  localhost:8083/connectors/ -d '{
  "name": "postgres-sink-connector",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "tasks.max": "1",
    "topics": "dbserver1.public.fruits",
    "dialect.name": "PostgreSqlDatabaseDialect",
    "table.name.format": "fruits",
    "connection.url": "jdbc:postgresql://pg:5432/postgres?user=postgres&password=postgres",
    "auto.create": "true",
    "insert.mode": "upsert",
    "pk.fields": "id",
    "pk.mode": "record_key",
    "delete.enabled": "true",
    "transforms": "unwrap,FilterOrigin,ReplaceField",
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "transforms.unwrap.drop.tombstones": "false",
    "transforms.unwrap.delete.handling.mode": "rewrite",
    "transforms.FilterOrigin.type":"io.confluent.connect.transforms.Filter$Value",
    "transforms.FilterOrigin.filter.condition":"$[?(@.origin_db == '\''main_table'\'')]",
    "transforms.FilterOrigin.filter.type":"include",
    "transforms.FilterOrigin.missing.or.null.behavior":"exclude",
    "transforms.ReplaceField.type": "io.confluent.connect.transforms.ReplaceField$Value",
    "transforms.ReplaceField.exclude": "origin_db",
    "key.converter":"org.apache.kafka.connect.json.JsonConverter",
    "value.converter":"org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable":"true",
    "value.converter.schemas.enable":"true"
  }
}'
```

10. Log into the Postgres container and check that sink table matches the source table:

```sh
docker run --network=logical-replication-with-confluent_default -it --rm --name postgresqlterm --link pg:postgresql --rm postgres:11.2 sh -c 'PGPASSWORD=postgres exec psql -h pg -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
```

and then query the table `fruits`:
```sql
SELECT * FROM fruits;
```
