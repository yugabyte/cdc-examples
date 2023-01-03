#!/bin/bash

echo "Using S3 path: ${S3_PATH}"
echo "Using AWS region: ${AWS_REGION}"

printf "Deploying iceberg sink connectors"
sleep 2;

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-warehouse",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_warehouse_district_item.public.warehouse",
        "upsert.keep-deletes": "false",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-district",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_warehouse_district_item.public.district",
        "upsert.keep-deletes": "false",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-item",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_warehouse_district_item.public.item",
        "upsert.keep-deletes": "false",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-stock",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_stock.public.stock",
        "upsert.keep-deletes": "false",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-new_order",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_new_order.public.new_order",
        "upsert.keep-deletes": "false",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-customer",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_customer_oorder.public.customer",
        "upsert.keep-deletes": "false",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-oorder",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_customer_oorder.public.oorder",
        "upsert.keep-deletes": "false",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-order_line",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_order_line.public.order_line",
        "upsert.keep-deletes": "false",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

sleep 2;
printf "\n\nDeploying trace connectors for iceberg"
sleep 2;
sleep 2;

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-trace-warehouse",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_warehouse_district_item.public.warehouse",
        "upsert": "false",
        "upsert.keep-deletes": "true",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "trace_",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-trace-district",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_warehouse_district_item.public.district",
        "upsert": "false",
        "upsert.keep-deletes": "true",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "trace_",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-trace-item",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_warehouse_district_item.public.item",
        "upsert": "false",
        "upsert.keep-deletes": "true",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "trace_",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-trace-stock",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_stock.public.stock",
        "upsert": "false",
        "upsert.keep-deletes": "true",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "trace_",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-trace-new_order",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_new_order.public.new_order",
        "upsert": "false",
        "upsert.keep-deletes": "true",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "trace_",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-trace-customer",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_customer_oorder.public.customer",
        "upsert": "false",
        "upsert.keep-deletes": "true",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "trace_",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-trace-oorder",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_customer_oorder.public.oorder",
        "upsert": "false",
        "upsert.keep-deletes": "true",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "trace_",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
    "name": "iceberg-trace-order_line",
    "config": {
        "connector.class":"com.getindata.kafka.connect.iceberg.sink.IcebergSink",
        "tasks.max": "1",
        "topics": "ybconnector_order_line.public.order_line",
        "upsert": "false",
        "upsert.keep-deletes": "true",
        "table.auto-create": "true",
        "table.write-format": "parquet",
        "table.namespace": "iceberg_tpcc",
        "table.prefix": "trace_",
        "iceberg.catalog-impl": "org.apache.iceberg.aws.glue.GlueCatalog",
        "iceberg.warehouse": "'${S3_PATH}'",
        "iceberg.fs.defaultFS": "'${S3_PATH}'",
        "iceberg.com.amazonaws.services.s3.enableV4": "true",
        "iceberg.com.amazonaws.services.s3a.enableV4": "true",
        "iceberg.fs.s3a.aws.credentials.provider": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
        "iceberg.fs.s3a.path.style.access": "true",
        "iceberg.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",
        "iceberg.aws.region": "'${AWS_REGION}'"
    }
}'

