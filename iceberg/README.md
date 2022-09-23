# Export to S3 using Iceberg Table Format

## Setup Yugabyte

Follow instructions in [Quick Start](https://docs.yugabyte.com/preview/quick-start-yugabytedb-managed/)
to start up a YugabyteDB cluster.

### Setup Tables and CDCSDK Stream

The dataset emulates a simple IOT workload. The workload consists of two tables:


    CREATE TABLE host (
	    id int PRIMARY KEY,
    	host_name TEXT,
	    LOCATION jsonb
    );

    CREATE TABLE host_data (
	    date timestamptz NOT NULL,
    	host_id int NOT NULL,
	    cpu double PRECISION,
    	tempc int,
	    status TEXT	
    );


Use ysqlsh to setup the tables

    # Store YugabyteDB Master IP addresses in an env variable

    export MASTER_ADDRESSES=<list of addresses>

    # Drop if required.
    ysqlsh -f drop_schema.sql
    
    # Create tables and functions.
    ysqlsh -f create_schema.sql

    # Setup CDCSDK Stream
    yb-admin create_change_data_stream ysql.yugabyte --master_addresses $MASTER_ADDRESSES

    # Save the output of the previous command in an env variable.
    export CDC_SDK_STREAM_ID=<id from previous command>

    # Save the IP address of a Yugabyte master in an env variable
    export PGHOST=<MASTER IP ADDRESS>

## Setup Kafka/Confluent Cloud

Use an existing installation of Apache Kafka or use Confluent Cloud.


OR


Follow instructions in [Quick Start](https://docs.confluent.io/platform/current/platform-quickstart.html#quick-start-for-cp)
to start up the Confluent Platform using Docker and Docker Compose.

### Create Kafka Topics

In [Confluent Center](https://docs.confluent.io/platform/current/platform-quickstart.html#create-the-pageviews-topic),
create two Kafka Topics:

* iceberg.public.host
* iceberg.public.host_data

### Start Kafka Connect using Docker

    # Store parameters in env variables:
    export BOOTSTRAP_SERVERS=<Kafka Bootstrap Server IP Addresses>
    export AWS_ACCESS_KEY_ID=<AWS Access Key ID>
    export AWS_SECRET_ACCESS_KEY=<AWS Secret Access Key>
    export AWS_SESSION_TOKEN=<AWS Session Token>
    export AWS_REGION=<AWS Region of the S3 Bucket>

    docker compose -f connect.yaml up -d

## Setup AWS Glue & Athena

In this example, Apache Iceberg uses AWS Glue as the table catalog. 
Install and configure [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

OR

Use AWS Console to setup AWS S3, AWS Glue and AWS Athena.


    # Create a database
    aws glue create-database --database-input "{\"Name\":\"yb_cdc\"}" --endpoint https://${AWS_REGION}.amazonaws.com

    export S3_PATH=<Path to a S3 directory e.g. s3://example/iceberg/>

## Setup Source and Sink Connectors

### Iceberg Sink Connectors

The script sets up two connectors:
* replicate: Replicates the tables in Yugabyte by applying inserts, updates and
  deletes.
* trace: Adds a row for inserts, updates and deletes and does not apply them.

Replicate tables are named:
* public_host
* public_host_data

Trace tables are named:
* trace_public_host
* trace_public_host_data

    ./iceberg-sink.sh


### Yugabyte Source Connector

    ./yb-connect.sh
