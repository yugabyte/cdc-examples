#!/usr/bin/env bash

# Deploy connector 1
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector1",
  "config": {
    "tasks.max":"1",
    "connector.class": "io.debezium.connector.postgresql.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "topic.prefix":"ybconnector1",
    "snapshot.mode":"initial",
    "table.include.list":"public.orders[a-zA-Z0-9]*",
    "key.converter":"io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url":"http://schema-registry:8081",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url":"http://schema-registry:8081",
    "plugin.name":"yboutput",
    "slot.name":"slot1"
  }
}'

sleep 1;

# Deploy connector 2
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector2",
  "config": {
    "tasks.max":"1",
    "connector.class": "io.debezium.connector.postgresql.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "topic.prefix":"ybconnector2",
    "snapshot.mode":"initial",
    "table.include.list":"public.products",
    "key.converter":"io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url":"http://schema-registry:8081",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url":"http://schema-registry:8081",
    "plugin.name":"yboutput",
    "slot.name":"slot2"
  }
}'

sleep 1;

# Deploy connector 3
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector3",
  "config": {
    "tasks.max":"1",
    "connector.class": "io.debezium.connector.postgresql.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "topic.prefix":"ybconnector3",
    "snapshot.mode":"initial",
    "table.include.list":"public.users",
    "key.converter":"io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url":"http://schema-registry:8081",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url":"http://schema-registry:8081",
    "plugin.name":"yboutput",
    "slot.name":"slot3"
  }
}'

sleep 1;

# Deploy connector 4
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector4",
  "config": {
    "tasks.max":"1",
    "connector.class": "io.debezium.connector.postgresql.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "topic.prefix":"ybconnector4",
    "snapshot.mode":"initial",
    "table.include.list":"public.reviews",
    "key.converter":"io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url":"http://schema-registry:8081",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url":"http://schema-registry:8081",
    "plugin.name":"yboutput",
    "slot.name":"slot4"
  }
}'

sleep 1;
