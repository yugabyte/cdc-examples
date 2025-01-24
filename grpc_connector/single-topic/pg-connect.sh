#!/bin/bash
set -xe
FILE=$1

if test -f "$FILE"; then
    export $(grep -v '^#' $FILE | xargs)
fi

payload() {
    cat << EOF
{
    "name": "jdbc-sink-pg",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",    
        "tasks.max": "1",
        "topics": "${TOPIC_PREFIX}_all_events",
        "dialect.name": "PostgreSqlDatabaseDialect",
        "connection.url": "jdbc:postgresql://$PGHOST:5432/postgres?user=postgres&password=postgres&sslMode=require",    
        "transforms": "KeyFieldExample,ReplaceField,unwrap",
        "transforms.KeyFieldExample.type": "io.aiven.kafka.connect.transforms.ExtractTopic\$Key",
        "transforms.KeyFieldExample.field.name": "__dbz__physicalTableIdentifier",
        "transforms.KeyFieldExample.skip.missing.or.null": "true",
        "transforms.ReplaceField.type": "org.apache.kafka.connect.transforms.ReplaceField\$Key",
        "transforms.ReplaceField.blacklist": "__dbz__physicalTableIdentifier",
        "transforms.unwrap.type": "io.debezium.connector.yugabytedb.transforms.YBExtractNewRecordState",   
        "transforms.unwrap.drop.tombstones": "false",
        "auto.create": "true",
        "insert.mode": "upsert",
        "pk.mode": "record_key",
        "delete.enabled": "true",
        "auto.evolve":"true"
    }
}
EOF
}

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d "$(payload)"
