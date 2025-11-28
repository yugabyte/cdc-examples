package com.dbzapp;

import java.util.Properties;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Options;

/**
 * Helper class to parse the command line options.
 * 
 * @author Sumukh Phalgaonkar
 */
public class CmdLineOpts {
  private final String connectorClass = "io.debezium.connector.postgresql.YugabyteDBConnector";
  public String hostname = "";
  public String databasePort = "5433";
  public String slotName = "test_slot";
  public String publicationName = "pub";
  public String databaseName = "yugabyte";
  public String databasePassword = "";
  public String databaseUser = "";
  public String snapshotMode = "never";
  public String pluginName = "yboutput";
  public String topicPrefix = "dbserver1";

  public static CmdLineOpts createFromArgs(String[] args) {
    Options options = new Options();

    options.addOption("slot_name", true, "Replication slot name");
    options.addOption("publication_name", true, "Publication name");
    options.addOption("plugin_name", true, "Plugin name");
    options.addOption("topic_prefix", true, "Topic prefix");
    options.addOption("hostname", true, "Database hostname");
    options.addOption("port", true, "Database port");
    options.addOption("database_name", true, "Database name");
    options.addOption("database_user", true, "Database user");
    options.addOption("database_password", true, "Database password");

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
    if (commandLine.hasOption("slot_name")) {
      slotName = commandLine.getOptionValue("slot_name");
    }

    if (commandLine.hasOption("publication_name")) {
      publicationName = commandLine.getOptionValue("publication_name");
    }

    if (commandLine.hasOption("plugin_name")) {
      pluginName = commandLine.getOptionValue("plugin_name");
    }

    if (commandLine.hasOption("topic_prefix")) {
      topicPrefix = commandLine.getOptionValue("topic_prefix");
    }

    if (commandLine.hasOption("hostname")) {
      hostname = commandLine.getOptionValue("hostname");
    }

    if (commandLine.hasOption("port")) {
      databasePort = commandLine.getOptionValue("port");
    }

    if (commandLine.hasOption("database_name")) {
      databaseName = commandLine.getOptionValue("database_name");
    }

    if (commandLine.hasOption("database_user")) {
      databaseUser = commandLine.getOptionValue("database_user");
    }

    if (commandLine.hasOption("database_password")) {
      databasePassword = commandLine.getOptionValue("database_password");
    }
  }

  public Properties asProperties() {
    Properties props = new Properties();
    props.setProperty("connector.class", connectorClass);
    props.setProperty("database.hostname", hostname);
    props.setProperty("database.port", databasePort);
    props.setProperty("database.user", databaseUser);
    props.setProperty("database.password", databasePassword);
    props.setProperty("database.dbname", databaseName);
    props.setProperty("database.server.name", "dbserver1");
    props.setProperty("snapshot.mode", snapshotMode);
    props.setProperty("plugin.name", pluginName);
    props.setProperty("publication.name", publicationName);
    props.setProperty("slot.name", slotName);
    props.setProperty("topic.prefix", topicPrefix);

    return props;
  }

}

