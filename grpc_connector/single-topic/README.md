# Single Topic Example

In a default setup, the debezium connector assumes there is a topic per table.
However, there are scenarios where it is required to multiplex messages from
many tables onto a single topic. For example, 
* There are thousands of tables and it is not possible to create as many
  topics.
* Messages are required in order.

This example provides the configuration to use a single topic for multiple
tables. 

## Basic Setup

Ensure that the following components are already setup:
* YugabyteDB Cluster
* Kafka
* Kafka Connect
* Postgresql

## TPCC Setup

The example uses TPCC tables. Setup the TPCC benchmark by following the
instructions in [Yugabyte docs](https://docs.yugabyte.com/preview/benchmark/tpcc-ysql/)

    # Create the tables
    ./tpccbenchmark --create=true --nodes=<CSV of YB Cluster IP/Host names>

    # Create a CDC Stream
    # Store YugabyteDB Master IP addresses in an env variable
    export MASTER_ADDRESSES=<list of addresses>

    # Setup CDCSDK Stream
    yb-admin create_change_data_stream ysql.yugabyte --master_addresses $MASTER_ADDRESSES

    # Save the output of the previous command in an env variable.
    export CDC_SDK_STREAM_ID=<id from previous command>

## Setup Debezium Yugabyte Connector

In default configuration, the connector will publish a message from a table
such as `public.stock` to `tpcc.public.stock` where `tpcc` is the value of
`database.server.name`. 

To reroute the messages to another topic,
**[ByLogicalTableRouter](https://debezium.io/documentation/reference/stable/transformations/topic-routing.html)** 
should be used. For example, to reroute all events to a topic
`tpcc_all_events`, the configuration required is:

        "transforms":"Reroute",
        "transforms.Reroute.type":"io.debezium.transforms.ByLogicalTableRouter",
        "transforms.Reroute.topic.regex":"(.*)",
        "transforms.Reroute.topic.replacement":"tpcc_all_events",

Some Kafka Connect sinks, use the name of the topic to determine the table or 
collection to apply the event to. For such sinks, a new field is added to the
key with the name of the table. The configuration required to add a new field
is:

        "transforms.Reroute.key.field.regex":"${TOPIC_PREFIX}.public.(.*)",
        "transforms.Reroute.key.field.replacement":"\$1"
 
 The above two lines, set a new field `__dbz__physicalTableIdentifier` to the
 name of the table e.g. `stock`.

    export PGHOST=<any host in the YugabyteDB cluster>
    export TOPIC_PREFIX=tpcc

    ./yb-connect.sh

## Setup the Postgres Sink Connector

In default mode, the JDBC Sink Connector reads events from multiple topics and
derives the name of the table from the topic name. Since there is a single
topic, the connector configuration has to use `__dbz__physicalTableIdentifier`
to determin the destination table. The configuration required is:

    "topics": "${TOPIC_PREFIX}_all_events",
    "dialect.name": "PostgreSqlDatabaseDialect",
    "transforms": "KeyFieldExample,unwrap",
    "transforms.KeyFieldExample.type": "io.aiven.kafka.connect.transforms.ExtractTopic\$Key",
    "transforms.KeyFieldExample.field.name": "__dbz__physicalTableIdentifier",
    "transforms.KeyFieldExample.skip.missing.or.null": "true",

The connector reads events from a single topic `tpcc`. A new SMT **ExtractTopic**
is used to extract the virtual topic from `__dbz__physicalTableIdentifier`. The
virtual topic is used determine the name of the destination table.

    ./pg-connect.sh
 

