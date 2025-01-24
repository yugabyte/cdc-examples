FROM alpine/git
WORKDIR /app
RUN git clone --depth 1 --branch release-0.1.3 https://github.com/getindata/kafka-connect-iceberg-sink.git

FROM maven:3.8.6-openjdk-18
WORKDIR /app
COPY --from=0 /app/kafka-connect-iceberg-sink /app
RUN mvn -ntp clean package -DskipTests

FROM quay.io/yugabyte/debezium-connector:1.7.0.13-BETA
COPY --from=1 /app/target/kafka-connect-*shaded.jar /kafka/connect
