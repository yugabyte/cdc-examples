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
    "name": "yb-connector-tpcc",
    "config": {
        "connector.class":"io.debezium.connector.yugabytedb.YugabyteDBConnector",    
        "tasks.max": "${num_tables}",
        "database.hostname":"${PGHOST}",
        "database.port":"5433",
        "database.master.addresses": "${PGHOST}:7100",
        "database.user": "${PGUSER}",
        "database.password": "${PGPASSWORD}",
        "database.dbname" : "${PGDATABASE}",
        "database.server.name": "${TOPIC_PREFIX}",
        "table.include.list":"${TABLES}",
        "database.streamid":"${CDC_SDK_STREAM_ID}",
        "snapshot.mode":"never",
    }
}
EOF
}

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d "$(payload)"
