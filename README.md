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
