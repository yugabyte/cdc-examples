#!/usr/bin/env bash

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "jdbc-sink-1",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
     "tasks.max": "1",
      "topics": "ybconnector1.public.orders",
      "dialect.name": "PostgreSqlDatabaseDialect",
      "table.name.format": "orders",
      "connection.url": "jdbc:postgresql://pg:5432/postgres?user=postgres&password=postgres&sslMode=require",
      "auto.create": "true",
      "auto.evolve":"true",
      "insert.mode": "upsert",
      "pk.fields": "id",
      "pk.mode": "record_key",
      "delete.enabled":"true",
      "transforms": "unwrap",
      "transforms.unwrap.type": "io.debezium.connector.postgresql.transforms.yugabytedb.YBExtractNewRecordState",
      "transforms.unwrap.drop.tombstones": "false",
      "key.converter":"io.confluent.connect.avro.AvroConverter",
      "key.converter.schema.registry.url":"http://schema-registry:8081",
      "value.converter":"io.confluent.connect.avro.AvroConverter",
      "value.converter.schema.registry.url":"http://schema-registry:8081"
   }
}'

sleep 1;

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "jdbc-sink-2",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
     "tasks.max": "1",
      "topics": "ybconnector2.public.products",
      "dialect.name": "PostgreSqlDatabaseDialect",
      "table.name.format": "products",
      "connection.url": "jdbc:postgresql://pg:5432/postgres?user=postgres&password=postgres&sslMode=require",
      "auto.create": "true",
      "auto.evolve":"true",
      "insert.mode": "upsert",
      "pk.fields": "id",
      "pk.mode": "record_key",
      "delete.enabled":"true",
      "transforms": "unwrap",
      "transforms.unwrap.type": "io.debezium.connector.postgresql.transforms.yugabytedb.YBExtractNewRecordState",
      "transforms.unwrap.drop.tombstones": "false",
      "key.converter":"io.confluent.connect.avro.AvroConverter",
      "key.converter.schema.registry.url":"http://schema-registry:8081",
      "value.converter":"io.confluent.connect.avro.AvroConverter",
      "value.converter.schema.registry.url":"http://schema-registry:8081"
   }
}'

sleep 1;

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "jdbc-sink-3",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
     "tasks.max": "1",
      "topics": "ybconnector3.public.users",
      "dialect.name": "PostgreSqlDatabaseDialect",
      "table.name.format": "users",
      "connection.url": "jdbc:postgresql://pg:5432/postgres?user=postgres&password=postgres&sslMode=require",
      "auto.create": "true",
      "auto.evolve":"true",
      "insert.mode": "upsert",
      "pk.fields": "id",
      "pk.mode": "record_key",
      "delete.enabled":"true",
      "transforms": "unwrap",
      "transforms.unwrap.type": "io.debezium.connector.postgresql.transforms.yugabytedb.YBExtractNewRecordState",
      "transforms.unwrap.drop.tombstones": "false",
      "key.converter":"io.confluent.connect.avro.AvroConverter",
      "key.converter.schema.registry.url":"http://schema-registry:8081",
      "value.converter":"io.confluent.connect.avro.AvroConverter",
      "value.converter.schema.registry.url":"http://schema-registry:8081"
   }
}'

sleep 1;

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "jdbc-sink-4",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
     "tasks.max": "1",
      "topics": "ybconnector4.public.reviews",
      "dialect.name": "PostgreSqlDatabaseDialect",
      "table.name.format": "reviews",
      "connection.url": "jdbc:postgresql://pg:5432/postgres?user=postgres&password=postgres&sslMode=require",
      "auto.create": "true",
      "auto.evolve":"true",
      "insert.mode": "upsert",
      "pk.fields": "id",
      "pk.mode": "record_key",
      "delete.enabled":"true",
      "transforms": "unwrap",
      "transforms.unwrap.type": "io.debezium.connector.postgresql.transforms.yugabytedb.YBExtractNewRecordState",
      "transforms.unwrap.drop.tombstones": "false",
      "key.converter":"io.confluent.connect.avro.AvroConverter",
      "key.converter.schema.registry.url":"http://schema-registry:8081",
      "value.converter":"io.confluent.connect.avro.AvroConverter",
      "value.converter.schema.registry.url":"http://schema-registry:8081"
   }
}'
