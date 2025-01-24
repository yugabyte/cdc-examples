#!/bin/bash
set -xe
FILE=$1

if test -f "$FILE"; then
    export $(grep -v '^#' $FILE | xargs)
fi

export PATH=$PATH:$YBPATH
TABLES="public.host,public.host_data"

payload_replicate() {
    cat << EOF
{
    "name": "iceberg-${FQDN[0]}-${FQDN[1]}",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink", 
        "tasks.max": "1",
        "topics": "iceberg.${table}",

        "upsert.keep-deletes": "false",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "yb_cdc",
        "table.prefix": "",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "${S3_PATH}",
        "iceberg.fs.defaultFS": "${S3_PATH}",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "${AWS_REGION}"
    }
}
EOF
}

payload_trace() {
    cat << EOF
{
    "name": "iceberg-trace-${FQDN[0]}-${FQDN[1]}",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink", 
        "tasks.max": "1",
        "topics": "iceberg.${table}",

        "upsert": "false",
        "upsert.keep-deletes": "true",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "yb_cdc",
        "table.prefix": "trace_",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "${S3_PATH}",
        "iceberg.fs.defaultFS": "${S3_PATH}",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "${AWS_REGION}"
    }
}
EOF
}


IFS=',' read -ra TABLE_ARRAY <<< "$TABLES"
for table in "${TABLE_ARRAY[@]}"; do
    IFS='.' read -ra FQDN <<< "$table"
    curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d "$(payload_replicate)"
    curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d  "$(payload_trace)"
done
