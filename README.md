# CDC Examples

Example Pipelines for Yugabyte CDC.

## Table of Contents

|Example|Description|
|-------|-----------|
|[Quick Start](cdc-quickstart-kafka-connect/README.md)|Setup a complete CDC pipeline using Docker containers in a single VM to Postgres|
|[Multi-Node Setup](multi-setup/README.md)|Distribute a CDC Pipeline across multiple nodes|
|[Iceberg on S3](iceberg/README.md)|Write records to Amazon S3 using Iceberg Table Format|
|[Iceberg with TPCC](iceberg-with-tpcc/README.md)|Write records to Amazon S3 with TPCC workload and before image enabled|
|[Use a Single Kafka Topic](single-topic/README.md)|Use a Single topic for multiple tables for CDC|
|[Content Based Routing](content-based-routing/README.md)|Re-route CDC events to different kafka topics based on the event content|
|[Authorization](authorization/README.md)|Setup CDC with a kafka cluster that has authentication and authorization enabled|
|[Striim Compatible Transform](striim-transform/README.md)|Transform the connector records to be compatible with Striim|
|[Protobuf Binary Data](protobuf-binary-data/)|Setup CDC on a table that stores protobuf message in binary and re-create the message from binary data in other microservice that reads from kafka|
|[Debezium Engine App](debezium-engine-app)| A Java App that prints change events from Yugabyte DB|
