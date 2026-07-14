package com.dbzapp;

/**
 * Sample application class to demonstrate working of Debezium Embedded Engine with YugabyteDB PostgreSQL connector.
 * 
 * @author Sumukh Phalgaonkar
 */
public class App {
  public static void main(String[] args) {
    System.out.println("Starting embedded application to run DBZ Embedded engine with YugabyteDB LR connector");

    CmdLineOpts configuration = CmdLineOpts.createFromArgs(args);
    try {
      EngineRunner engineRunner = new EngineRunner(configuration);
      engineRunner.run();
    } catch (Exception e) {
      System.out.println("Exception while trying to run the engine: " + e);
      System.exit(-1);
    }
  }
}

