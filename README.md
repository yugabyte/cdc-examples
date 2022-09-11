# CDC-Monitoring
This repo provides tools to monitor cdc using prometheus to scrape the metrics and grafana to plot graphs on the collected metric data.

## Pre-requisites
Ensure that docker and docker compose is installed.
We will need an instance of YugabyteDB running with a stream created on it.

## Creating the "env" file
We will need to create a "settings.env" file to provide config information to the docker containers.

|Settings|Description|
|--------|------------|
|KAFKA_HOST| Host and port where Kafka is running|
|USERID| uid that docker processes should use. Get from `id -u ${USER}`|

## Running with Kafka Connect

   docker compose --env-file <path-to>/settings.env -d

## Connecting the source connector

   curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" \
  localhost:8083/connectors/ \
  -d '{
  "name": "ybconnector",
  "config": {
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname": "<Address-of-YB-cluster>",
    "database.port":"5433",
    "database.master.addresses": "<Address-of-YB-cluster>:7100",
    "database.user": "yugabyte",
    "database.password": "yugabyte",
    "database.dbname" : "yugabyte",
    "database.server.name": "dbserver1",
    "table.include.list":"<namespace-name>.<table-name>",
    "database.streamid":"<stream-id>",
    "key.converter.schemas.enable":"false",
    "value.converter.schemas.enable":"false",
    "transforms":"unwrap",
    "transforms.unwrap.type":"io.debezium.connector.yugabytedb.transforms.YBExtractNewRecordState",
    "snapshot.mode":"<initial/never>"
  }
}'
