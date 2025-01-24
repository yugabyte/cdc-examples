package com.dbzapp;

import java.util.Properties;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Options;

/**
 * Helper class to parse the command line options.
 * 
 * @author Sumukh Phalgaonkar, Vaibhav Kushwaha (vkushwaha@yugabyte.com)
 */
public class CmdLineOpts {
  private final String connectorClass = "io.debezium.connector.yugabytedb.YugabyteDBConnector";
  public String masterAddresses;
  public String hostname;
  public String databasePort = "5433";
  public String streamId;
  public String tableIncludeList;
  public String databaseName = "yugabyte";
  public String databasePassword = "Yugabyte@123";
  public String databaseUser = "yugabyte";
  public String snapshotMode = "never";

  public static CmdLineOpts createFromArgs(String[] args) {
    Options options = new Options();

    options.addOption("master_addresses", true, "Addresses of the master process");
    options.addOption("stream_id", true, "DB stream ID");
    options.addOption("table_include_list", true, "The table list to poll for in the form"
                      + " <schemaName>.<tableName>");

    CommandLineParser parser = new DefaultParser();
    CommandLine commandLine = null;
    try {
      commandLine = parser.parse(options, args);
    } catch (Exception e) {
      System.out.println("Exception while parsing arguments: " + e);
      System.exit(-1);
    }

    CmdLineOpts configuration = new CmdLineOpts();
    configuration.initialize(commandLine);
    return configuration;
  }

  private void initialize(CommandLine commandLine) {
    if (commandLine.hasOption("master_addresses")) {
      masterAddresses = commandLine.getOptionValue("master_addresses");
      String[] nodes = masterAddresses.split(",");
      hostname = nodes[0].split(":")[0];
    }

    if (commandLine.hasOption("stream_id")) {
      streamId = commandLine.getOptionValue("stream_id");
    }

    if (commandLine.hasOption("table_include_list")) {
      tableIncludeList = commandLine.getOptionValue("table_include_list");
    }
  }

  public Properties asProperties() {
    Properties props = new Properties();
    props.setProperty("connector.class", connectorClass);

    props.setProperty("database.streamid", streamId);
    props.setProperty("database.master.addresses", masterAddresses);
    props.setProperty("table.include.list", tableIncludeList);
    props.setProperty("database.hostname", hostname);
    props.setProperty("database.port", databasePort);
    props.setProperty("database.user", databaseUser);
    props.setProperty("database.password", databasePassword);
    props.setProperty("database.dbname", databaseName);
    props.setProperty("database.server.name", "dbserver1");
    props.setProperty("snapshot.mode", snapshotMode);

    return props;
  }

}
