FROM confluentinc/cp-kafka-connect:7.7.5

# Install Confluent transforms (includes Filter and ReplaceField transforms)
RUN confluent-hub install --no-prompt confluentinc/connect-transforms:latest

# Install JDBC Sink Connector
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:latest

# Create directory for YugabyteDB connector
RUN mkdir -p /usr/share/confluent-hub-components/debezium-connector-yugabytedb/

# Copy YugabyteDB connector JAR
COPY yugabytedb-source-connector-dz.2.5.2.yb.2024.2.5-jar-with-dependencies.jar /usr/share/confluent-hub-components/debezium-connector-yugabytedb/

