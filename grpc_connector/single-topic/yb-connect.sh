#!/bin/bash
set -xe
FILE=$1

if test -f "$FILE"; then
    export $(grep -v '^#' $FILE | xargs)
fi

payload() {
    cat << EOF
{
    "name": "yb-connector-tpcc",
    "config": {
        "connector.class":"io.debezium.connector.yugabytedb.YugabyteDBConnector",    
        "tasks.max": "1",
        "topics_regex": "${TOPIC_PREFIX}.public.(.*)",
        "database.hostname":"${PGHOST}",
        "database.port":"5433",
        "database.master.addresses": "${PGHOST}:7100",
        "database.user": "yugabyte",
        "database.password": "yugabyte",
        "database.dbname" : "yugabyte",
        "database.server.name": "${TOPIC_PREFIX}",
        "table.include.list":"${TABLES}",
        "database.streamid":"${CDC_SDK_STREAM_ID}",
        "snapshot.mode":"never",
        "consistency.mode":"${CMODE:-default}",
        "transforms":"Reroute",
        "transforms.Reroute.type":"io.debezium.transforms.ByLogicalTableRouter",
        "transforms.Reroute.topic.regex":"(.*)",
        "transforms.Reroute.topic.replacement":"${TOPIC_PREFIX}_all_events",
        "transforms.Reroute.key.field.regex":"${TOPIC_PREFIX}.public.(.*)",
        "transforms.Reroute.key.field.replacement":"\$1"
    }
}
EOF
}

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d "$(payload)"
