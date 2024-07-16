#!/usr/bin/env bash

# Deploy connector 1
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
    "table.include.list":"public.orders[a-zA-Z0-9]*",
    "new.table.poll.interval.ms":"5000",
    "key.converter":"io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url":"http://schema-registry:8081",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url":"http://schema-registry:8081",
    "producer.override.sasl.jaas.config":"org.apache.kafka.common.security.plain.PlainLoginModule required username=\"source_connector\" password=\"source-secret\";"
  }
}'

sleep 1;

# Deploy connector 2
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector2",
  "config": {
    "tasks.max":"2",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.master.addresses":"'$MASTERS'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "database.server.name":"ybconnector2",
    "snapshot.mode":"initial",
    "database.streamid":"'$1'",
    "table.include.list":"public.products",
    "key.converter":"io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url":"http://schema-registry:8081",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url":"http://schema-registry:8081",
    "producer.override.sasl.jaas.config":"org.apache.kafka.common.security.plain.PlainLoginModule required username=\"source_connector\" password=\"source-secret\";"
  }
}'

sleep 1;

# Deploy connector 3
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector3",
  "config": {
    "tasks.max":"2",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.master.addresses":"'$MASTERS'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "database.server.name":"ybconnector3",
    "snapshot.mode":"initial",
    "database.streamid":"'$1'",
    "table.include.list":"public.users",
    "key.converter":"io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url":"http://schema-registry:8081",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url":"http://schema-registry:8081",
    "producer.override.sasl.jaas.config":"org.apache.kafka.common.security.plain.PlainLoginModule required username=\"source_connector\" password=\"source-secret\";"
  }
}'

sleep 1;

# Deploy connector 4
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector4",
  "config": {
    "tasks.max":"2",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.master.addresses":"'$MASTERS'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "database.server.name":"ybconnector4",
    "snapshot.mode":"initial",
    "database.streamid":"'$1'",
    "table.include.list":"public.reviews",
    "key.converter":"io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url":"http://schema-registry:8081",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url":"http://schema-registry:8081",
    "producer.override.sasl.jaas.config":"org.apache.kafka.common.security.plain.PlainLoginModule required username=\"source_connector\" password=\"source-secret\";"
  }
}'

sleep 1;
