#!/usr/bin/env bash

# Deploy connector 1
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector1",
  "config": {
    "tasks.max":"1",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.master.addresses":"'$MASTERS'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "database.server.name":"dbserver1",
    "snapshot.mode":"never",
    "database.streamid":"'$1'",
    "table.include.list":"'$2'",
    "transaction.ordering":"true",
    "transforms":"Reroute",
    "transforms.Reroute.topic.regex":"(.*)",
    "transforms.Reroute.topic.replacement":"dbserver1_all_events",
    "transforms.Reroute.type":"io.debezium.transforms.ByLogicalTableRouter",
    "transforms.Reroute.key.field.regex":"dbserver1.public.(.*)",
    "transforms.Reroute.key.field.replacement":"$1"
  }
}'
