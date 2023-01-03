#!/bin/bash

echo "Masters are at ${MASTER_ADDRESSES}"
echo "Database hostname being used is ${PG_HOSTNAME}"
echo "DB Stream ID: ${CDCSDK_STREAM_ID}"

# Check AWS connection

# Deploy the connector
echo "Deploying connector for tables: warehouse district item"

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector_warehouse_district_item",
  "config": {
    "tasks.max":"3",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'${PG_HOST}'",
    "database.master.addresses":"'${MASTER_ADDRESSES}'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"yugabyte",
    "database.dbname":"yugabyte",
    "database.server.name": "ybconnector_warehouse_district_item",
    "snapshot.mode":"never",
    "table.include.list":"public.warehouse,public.district,public.item",
    "transforms":"unwrap",
    "transforms.unwrap.type":"io.debezium.connector.yugabytedb.transforms.PGCompatible",
    "transforms.unwrap.drop.tombstones":"false",
    "tombstones.on.delete":"false",
    "database.streamid":"'${CDCSDK_STREAM_ID}'"
  }
}'

sleep 2;

printf "\n\nDeploying connector for tables: stock"

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector_stock",
  "config": {
    "tasks.max":"4",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'${PG_HOST}'",
    "database.master.addresses":"'${MASTER_ADDRESSES}'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"yugabyte",
    "database.dbname":"yugabyte",
    "database.server.name": "ybconnector_stock",
    "snapshot.mode":"never",
    "table.include.list":"public.stock",
    "transforms":"unwrap",
    "transforms.unwrap.type":"io.debezium.connector.yugabytedb.transforms.PGCompatible",
    "transforms.unwrap.drop.tombstones":"false",
    "tombstones.on.delete":"false",
    "database.streamid":"'${CDCSDK_STREAM_ID}'"
  }
}'

sleep 2;

printf "\n\nDeploying connector for tables: new_order"

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector_new_order",
  "config": {
    "tasks.max":"4",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'${PG_HOST}'",
    "database.master.addresses":"'${MASTER_ADDRESSES}'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"yugabyte",
    "database.dbname":"yugabyte",
    "database.server.name": "ybconnector_new_order",
    "snapshot.mode":"never",
    "table.include.list":"public.new_order",
    "transforms":"unwrap",
    "transforms.unwrap.type":"io.debezium.connector.yugabytedb.transforms.PGCompatible",
    "transforms.unwrap.drop.tombstones":"false",
    "tombstones.on.delete":"false",
    "database.streamid":"'${CDCSDK_STREAM_ID}'"
  }
}'

sleep 2;

printf "\n\nDeploying connector for tables: customer oorder"

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector_customer_oorder",
  "config": {
    "tasks.max":"4",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'${PG_HOST}'",
    "database.master.addresses":"'${MASTER_ADDRESSES}'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"yugabyte",
    "database.dbname":"yugabyte",
    "database.server.name": "ybconnector_customer_oorder",
    "snapshot.mode":"never",
    "table.include.list":"public.customer,public.oorder",
    "transforms":"unwrap",
    "transforms.unwrap.type":"io.debezium.connector.yugabytedb.transforms.PGCompatible",
    "transforms.unwrap.drop.tombstones":"false",
    "tombstones.on.delete":"false",
    "database.streamid":"'${CDCSDK_STREAM_ID}'"
  }
}'

sleep 2;

printf "\n\nDeploying connector for tables: order_line"

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector_order_line",
  "config": {
    "tasks.max":"4",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'${PG_HOST}'",
    "database.master.addresses":"'${MASTER_ADDRESSES}'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"yugabyte",
    "database.dbname":"yugabyte",
    "database.server.name": "ybconnector_order_line",
    "snapshot.mode":"never",
    "table.include.list":"public.order_line",
    "transforms":"unwrap",
    "transforms.unwrap.type":"io.debezium.connector.yugabytedb.transforms.PGCompatible",
    "transforms.unwrap.drop.tombstones":"false",
    "tombstones.on.delete":"false",
    "database.streamid":"'${CDCSDK_STREAM_ID}'"
  }
}'

printf "\n\nYou can deploy iceberg sink connectors now"

