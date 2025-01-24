package com.example.protobuftest;

import com.example.protobuftest.proto.UserProto.User;
import org.apache.avro.generic.GenericData.Record;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.time.Duration;
import java.util.Arrays;
import java.util.Base64;
import java.util.Properties;

public class CdcConsumer {
    private static String KAFKA_TOPIC_NAME = "ybconnector1.public.users";

    private static Properties getKafkaProperties(boolean avroMode) {
        Properties config = new Properties();
        config.put(ConsumerConfig.CLIENT_ID_CONFIG, "testClient");
        config.put(ConsumerConfig.GROUP_ID_CONFIG, "testGroup");
        config.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");

        if (avroMode) {
            config.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, "io.confluent.kafka.serializers.KafkaAvroDeserializer");
            config.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, "io.confluent.kafka.serializers.KafkaAvroDeserializer");
            config.put("schema.registry.url", "http://localhost:8081");
        } else {
             config.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
             config.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
        }

        return config;
    }

    private static void processAvroRecord(Record record, String operation) {
        if (record == null) {
            return;
        }

        String message = operation + " performed on user.";

        Long userId = record.get("id") == null ? null : (Long) ((Record) record.get("id")).get("value");
        ByteBuffer userData = record.get("data") == null ? null : (ByteBuffer) ((Record) record.get("data")).get("value");

        if (userId != null) {
            message += "\nId: " + userId.toString();
        }

        if (userData != null) {
            try {
                User user =  User.parseFrom(userData);
                message += "\nData:\n" + user.toString();
            } catch (Exception e) {
                System.out.println("Couldn't parse bytes\n");
            }
        }

        message += "\n";
        System.out.println(message);
    }

    private static void processJsonRecord(JSONObject record, String operation) {
        if (record == null) {
            return;
        }

        String message = operation + " performed on user.";

        Long userId = record.isNull("id") ? null : ((JSONObject) record.get("id")).getLong("value");
        String userData = record.isNull("data")  ? null : ((JSONObject) record.get("data")).getString("value");

        if (userId != null) {
            message += "\nId: " + userId.toString();
        }

        if (userData != null) {
            try {
                byte[] bytes = Base64.getDecoder().decode(userData);
                User user =  User.parseFrom(bytes);
                message += "\nData:\n" + user.toString();
            } catch (Exception e) {
                System.out.println("Couldn't parse bytes\n");
            }
        }

        message += "\n";
        System.out.println(message);
    }

    private static void handleAvroRecords(KafkaConsumer consumer) {
        ConsumerRecords<Record, Record> records = consumer.poll(Duration.ofMillis(100));
        for (ConsumerRecord<Record, Record> record : records) {
            Record value = record.value();

            if (value == null) {
                continue;
            }

            switch (value.get("op").toString()) {
                case "r": {
                    processAvroRecord((Record) value.get("after"), "Read");
                    break;
                }
                case "c": {
                    processAvroRecord((Record) value.get("after"), "Create");
                    break;
                }
                case "d": {
                    processAvroRecord((Record) value.get("before"), "Delete");
                    break;
                }
                case "u": {
                    processAvroRecord((Record) value.get("after"), "Update");
                    break;
                }
                default: {
                    break;
                }
            }
        }
    }

    private static void handleJsonRecords(KafkaConsumer consumer) {
        ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
        for (ConsumerRecord<String, String> record : records) {
            String value = record.value();

            if (value == null) {
                continue;
            }

            JSONObject parsedValue = new JSONObject(value);
            JSONObject payload = parsedValue.getJSONObject("payload");

            if (payload == null) {
                continue;
            }

            switch (payload.getString("op")) {
                case "r": {
                    processJsonRecord((JSONObject) payload.get("after"), "Read");
                    break;
                }
                case "c": {
                    processJsonRecord((JSONObject) payload.get("after"), "Create");
                    break;
                }
                case "d": {
                    processJsonRecord((JSONObject) payload.get("before"), "Delete");
                    break;
                }
                case "u": {
                    processJsonRecord((JSONObject) payload.get("after"), "Update");
                    break;
                }
                default: {
                    break;
                }
            }
        }
    }

    public static void main(String[] args) {
        String mode = args.length > 0 ? args[0].toLowerCase() : "";

        if (!(mode.equals("avro") || mode.equals("json"))) {
            System.out.println("No/Invalid mode specified");
            return;
        }

        boolean avroMode = mode.equals("avro");
        Properties kafkaConfig = getKafkaProperties(avroMode);

        try (KafkaConsumer consumer = new KafkaConsumer(kafkaConfig)) {
            consumer.subscribe(Arrays.asList(KAFKA_TOPIC_NAME));
            while (true) {
                if (avroMode) {
                    handleAvroRecords(consumer);
                } else {
                    handleJsonRecords(consumer);
                }
            }
        }
    }
}
