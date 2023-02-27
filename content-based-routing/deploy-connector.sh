curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybconnector",
  "config": {
    "tasks.max":"2",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "database.hostname":"'$NODE'",
    "database.master.addresses":"'$MASTERS'",
    "database.port":"5433",
    "database.user": "yugabyte",
    "database.password":"Yugabyte@123",
    "database.dbname":"yugabyte",
    "database.server.name":"ybconnector",
    "snapshot.mode":"initial",
    "database.streamid":"'$1'",
    "table.include.list":"public.users",
    "key.converter":"io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url":"http://schema-registry:8081",
    "value.converter":"io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url":"http://schema-registry:8081",
    "transforms":"route1,route2,route3",
    "transforms.route1.type":"io.debezium.transforms.ContentBasedRouter",
    "transforms.route1.language":"jsr223.groovy",
    "transforms.route1.topic.expression":"value.after != null ? (value.after?.country?.value == '\''UK'\'' ? '\''uk_users'\'' : null) : (value.before?.country?.value == '\''UK'\'' ? '\''uk_users'\'' : null)",
    "transforms.route2.type":"io.debezium.transforms.ContentBasedRouter",
    "transforms.route2.language":"jsr223.groovy",
    "transforms.route2.topic.expression":"value.after != null ? (value.after?.country?.value == '\''India'\'' ? '\''india_users'\'' : null) : (value.before?.country?.value == '\''India'\'' ? '\''india_users'\'' : null)",
    "transforms.route3.type":"io.debezium.transforms.ContentBasedRouter",
    "transforms.route3.language":"jsr223.groovy",
    "transforms.route3.topic.expression":"value.after != null ? (value.after?.country?.value == '\''USA'\'' ? '\''usa_users'\'' : null) : (value.before?.country?.value == '\''USA'\'' ? '\''usa_users'\'' : null)"
  }
}'

sleep 1;
