# Striim Compatible Transformer

[Striim](https://www.striim.com) is a distributed data integration and intelligence platform that can be used to design, deploy, and run data movement and data streaming pipelines.

This repository contains simple steps to set up a YugabyteDB CDC pipeline with `StriimCompatible` transfomer that transforms the messages being sent to kafka in a format compatible with Striim's [WAEvent](https://www.striim.com/docs/en/postgresql-cdc.html#UUID-bb4c7685-acc1-6f6a-f4a2-afbfecf4febf).

## Setup

To use `StriimCompatible` transform with the connectors the following properties needs to be added to the connector configuration.

```json
"transforms": "unwrap",
"transforms.unwrap.type": "io.debezium.connector.yugabytedb.transforms.StriimCompatible",
```

**NOTE**: For this transform to work correctly you need to enable before image while creating the cdc stream. You can do it using the following command.

```
./yb-admin --master_addresses $MASTERS create_change_data_stream ysql.<namespace> IMPLICIT ALL
```

## Example

In the following example, we'll setup cdc with the `StriimCompatible` transform configured.

1. Start YugabyteDB
    This can be a local instance as well as a universe running on Yugabyte Anywhere. All you need is the IP of the nodes where the tserver and master processes are running.
    ```sh
    export NODE=<IP-OF-YOUR-NODE>
    export MASTERS=<MASTER-ADDRESSES>
    ```

2. Create a table
    This example uses the [Retail Analytics](https://docs.yugabyte.com/preview/sample-data/retail-analytics/) dataset provided by Yugabyte. Some of the SQL scripts are also copied in this repository for the ease of use, to create the table in the dataset, use the file

    ```sql
    \i scripts/schema.sql
    ```

3. Create a stream ID using yb-admin with before image enabled
    ```
    ./yb-admin --master_addresses $MASTERS create_change_data_stream ysql.<namespace> IMPLICIT ALL
    ```

4. Start the docker containers

    ```sh
    docker-compose up -d
    ```

5. Deploy the source connector:

    ```sh
    ./deploy.sh <stream-id-created-in-step-3>
    ```

6. To perform operations and insert data to the created tables, you can use other scripts bundled under scripts/
    ```sql
    \i scripts/users.sql;
    ```

### Example payloads

Here are few examples on how the records look like after this transform is applied.

#### CREATE
```json
{"metadata":{"LSN":"1:957::0:0","OperationName":"INSERT","PK_UPDATE":null,"Sequence":"[\"1:956::0:0\",\"1:957::0:0\"]","TableName":"public.users","TxnID":"<ByteString@31be56b6 size=0 contents=\"\">"},"data":["10","1534421790307","Tressa White","white.tressa@yahoo.com","13081-13217 Main Street","Upper Sandusky","OH","43351","1968-01-13","40.8006673","-83.2838391","81052233-b32e-43cb-9505-700dbd8d3fca","Google"],"columns":["id","created_at","name","email","address","city","state","zip","birth_date","latitude","longitude","password","source"],"before":null}
```

#### UPDATE
```json
{"metadata":{"LSN":"1:958::0:0","OperationName":"UPDATE","PK_UPDATE":null,"Sequence":"[\"1:957::0:0\",\"1:958::0:0\"]","TableName":"public.users","TxnID":"<ByteString@31be56b6 size=0 contents=\"\">"},"data":["10","1534421790307","Test Name","white.tressa@yahoo.com","13081-13217 Main Street","Upper Sandusky","OH","43351","1968-01-13","40.8006673","-83.2838391","81052233-b32e-43cb-9505-700dbd8d3fca","Google"],"columns":["id","created_at","name","email","address","city","state","zip","birth_date","latitude","longitude","password","source"],"before":["10",null,null,null,null,null,null,null,null,null,null,null,null]}
```

#### DELETE
```json
{"metadata":{"LSN":"1:959::0:0","OperationName":"DELETE","PK_UPDATE":null,"Sequence":"[\"1:958::0:0\",\"1:959::0:0\"]","TableName":"public.users","TxnID":"<ByteString@31be56b6 size=0 contents=\"\">"},"data":["10",null,null,null,null,null,null,null,null,null,null,null,null],"columns":["id","created_at","name","email","address","city","state","zip","birth_date","latitude","longitude","password","source"],"before":null}
```
