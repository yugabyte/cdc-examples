package com.dbzapp;

import io.debezium.connector.yugabytedb.*;
import io.debezium.engine.ChangeEvent;
import io.debezium.engine.DebeziumEngine;
import io.debezium.engine.format.Json;

import org.apache.kafka.connect.json.*;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Runner class to demonstrate Debezium Embedded engine in a class.
 * 
 * @author Sumukh Phalgaonkar, Vaibhav Kushwaha (vkushwaha@yugabyte.com)
 */
public class EngineRunner {
  private CmdLineOpts config;

  public EngineRunner(CmdLineOpts config) {
    this.config = config;
  }

  public void run() throws Exception {
    final Properties props = config.asProperties();
    props.setProperty("name", "engine");
    props.setProperty("offset.storage", "org.apache.kafka.connect.storage.FileOffsetBackingStore");
    props.setProperty("offset.storage.file.filename", "/tmp/offsets.dat");
    props.setProperty("offset.flush.interval.ms", "60000");

    // Create the engine with this configuration ...
    try (DebeziumEngine<ChangeEvent<String, String>> engine = DebeziumEngine.create(Json.class)
            .using(props)
            .notifying((records, committer) -> {
                for(ChangeEvent<String, String> record: records){
                    System.out.println(record);
                    committer.markProcessed((record));
                }
                committer.markBatchFinished();
            }).build()
        ) {
      // Run the engine asynchronously ...
      ExecutorService executor = Executors.newSingleThreadExecutor();
      executor.execute(engine);
    } catch (Exception e) {
      throw e;
    }
  }
}
