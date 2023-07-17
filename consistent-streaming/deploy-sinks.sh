echo "Deploying JDBC sink connector on with target on node $1"

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
"name": "jdbc-sink",
"config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "tasks.max": "1",
    "topics": "dbserver1_all_events",
    "dialect.name": "PostgreSqlDatabaseDialect",
    "connection.url": "jdbc:postgresql://'$1':5432/postgres?user=postgres&password=postgres&sslMode=require",
    "insert.mode": "upsert",
    "pk.mode": "record_key",
    "delete.enabled": "true",
    "auto.create": "false",
    "auto.evolve": "false",
    "consistent.writes": "true",
    "transforms": "KeyFieldExample,unwrap",
    "transforms.KeyFieldExample.type": "io.aiven.kafka.connect.transforms.ExtractTopic$Key",
    "transforms.KeyFieldExample.field.name": "__dbz__physicalTableIdentifier",
    "transforms.KeyFieldExample.skip.missing.or.null": "true",
    "transforms.unwrap.type": "io.debezium.connector.yugabytedb.transforms.YBExtractNewRecordState",
    "transforms.unwrap.drop.tombstones": "false"
  }
}'
