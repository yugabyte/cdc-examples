#!/bin/bash
set -xe
FILE=$1

if test -f "$FILE"; then
    export $(grep -v '^#' $FILE | xargs)
fi

export PATH=$PATH:$YBPATH
TABLES="public.host,public.host_data"

payload() {
    cat << EOF
{
    "name": "yb-connector-${FQDN[0]}-${FQDN[1]}",
    "config": {
        "connector.class":"io.debezium.connector.yugabytedb.YugabyteDBConnector",    
        "tasks.max": "1",
        "topics": "iceberg.${table}",
        "database.hostname":"${PGHOST}",
        "database.port":"5433",
        "database.master.addresses": "${PGHOST}:7100",
        "database.user": "yugabyte",
        "database.password": "yugabyte",
        "database.dbname" : "yugabyte",
        "database.server.name": "iceberg",
        "table.include.list":"${table}",
        "database.streamid":"${CDC_SDK_STREAM_ID}",
        "transforms":"unwrap",
        "transforms.unwrap.type":"io.debezium.connector.yugabytedb.transforms.PGCompatible",
        "snapshot.mode":"never"
    }
}
EOF
}

IFS=',' read -ra TABLE_ARRAY <<< "$TABLES"
for table in "${TABLE_ARRAY[@]}"; do
    IFS='.' read -ra FQDN <<< "$table"
    curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d "$(payload)"
done
