#!/bin/bash
set -xe
FILE=$1

if test -f "$FILE"; then
    export $(grep -v '^#' $FILE | xargs)
fi

num_tables=$(echo $TABLES | tr -cd , | wc -c)

payload() {
    cat << EOF
{
    "name": "jdbc-sink-pg",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",    
        "tasks.max": "${num_tables}",
        "topics.regex": "${TOPIC_PREFIX}.public.(.*)",
        "dialect.name": "PostgreSqlDatabaseDialect",
        "connection.url":"jdbc:postgresql://${PSQL_HOST}:5432/${PSQL_DB}?user=${PSQL_USER}&password=${PSQL_PWD}&sslMode=require", 
        "transforms": "dropPrefix, unwrap",
        "transforms.dropPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.dropPrefix.regex": "${TOPIC_PREFIX}.public.(.*)",
        "transforms.dropPrefix.replacement": "\$1",
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
