# Running TPCC workload on Iceberg with Before Image

## Contents
* [Steps to run the pipeline](#steps-to-run-the-pipeline)
* [Troubleshooting](#troubleshooting)

## Steps to run the pipeline

### 1. Setting up YugabyteDB
Follow [these instructions](https://docs.yugabyte.com/preview/quick-start-yugabytedb-managed/) to setup a YugabyteDB cluster

#### 2. TPCC setup
This example uses the TPCC workload, follow the instructions [here](https://docs.yugabyte.com/preview/benchmark/tpcc-ysql/) to set them up.

```sh
# Create the tables
./tpccbenchmark --create=true --nodes=<CSV of cluster IPs>
```

We will come back to run the load and execute phase later.

### 3. Setting up the environment variables

```sh
export AWS_ACCESS_KEY_ID=<aws-access-key-id>
export AWS_SECRET_ACCESS_KEY=aws-secret-access-key>
export AWS_SESSION_TOKEN=<aws-session-token>
export AWS_REGION=<aws-region>
export MASTER_ADDRESSES=<CSV of IP addresses of nodes where master process is running>
export PG_HOST=<IP of one of the tservers>
```

### 4. Create a S3 bucket and Setup AWS Glue

Create a S3 bucket named `tpcc-iceberg`

This command requires you to have AWS CLI installed and have the credentials setup properly.

```sh
aws glue create-database --database-input "{\"Name\":\"iceberg_tpcc\",\"LocationUri\":\"s3://tpcc-iceberg\"}" --endpoint https://glue.${AWS_REGION}.amazonaws.com

# Also export the S3 path
export S3_PATH=s3://tpcc-iceberg
```

### 5. Create a DB Stream ID using yb-admin

You will need to use [yb-admin](https://docs.yugabyte.com/preview/admin/yb-admin/#change-data-capture-cdc-commands) to create a DB stream ID with before image enabled. Run the following command:

```sh
./yb-admin --master_addresses ${MASTER_ADDRESSES} create_change_data_stream ysql.yugabyte IMPLICIT ALL
CDC Stream ID: d109c397bb734c1ba96dac70a9ab04a0
```

Copy the generated stream ID, note that this will be different for you than the one shown in the example here. Also note that we will be using the default database throughout our examples.

Now store the stream ID to the environment variable:

```sh
export CDCSDK_STREAM_ID=<DB-stream-id-you-generated>
```

### 6. Build the required container

```sh
docker build . -t connect-with-iceberg:latest
```

### 7. Start the docker containers

```sh
docker-compose up -f docker-compose.yaml
```

### 8. Deploy the source and sink connectors

```sh
# This deploys the source connectors
./setup-tpcc-yb.sh

# This deploys the sink connectors
./setup-tpcc-sink.sh
```

### 9. Start the TPCC load

```sh
./tpccbenchmark --load=true --warehouses=1 --nodes=<CSV of cluster IPs>
```

You can change the count of warehouses based on the configuration you want to run.

As soon as it starts to insert, the data will start coming up in your glue database and you can view the tables in AWS Athena then.

## Troubleshooting

Some errors which can happen often:
1. Error in specifying the credentials for AWS
2. In case you switch terminals windows to run separate commands, you will need to export the environment variables there only
3. If you need to delete the connectors, you can use:
   
   ```sh
   curl -X DELETE localhost:8083/connectors/<connector-name>
   ```
   
   If you want to delete all the connectors, use the specified scripts:
   
   ```sh
   # Delete source connectors
   ./delete-sources.sh
   
   # Delete sink connectors
   ./delete-sinks.sh
   ```
