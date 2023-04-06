#!/usr/bin/env bash

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector1",
  "config": {
    "tasks.max":"2",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.master.addresses":"'$MASTERS'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "database.server.name":"ybconnector1",
    "snapshot.mode":"initial",
    "database.streamid":"'$1'",
    "table.include.list":"public.users",
    "new.table.poll.interval.ms":"5000",
    "transforms": "unwrap",
    "transforms.unwrap.type": "io.debezium.connector.yugabytedb.transforms.StriimCompatible"
  }
}'
