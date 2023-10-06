const mongoose = require("mongoose");
const log = require('./log.js');

class Database {
  connection = mongoose.connection;

  constructor() {
    try {
      this.connection
        .on("open", function() { log.info("Database connection: open") } ) 
        .on("close", function() { log.info("Database connection: close") } )
        .on(
          "disconnected",
          function() { log.info("Database connection: disconnecting") }
        )
        .on(
          "reconnected",
          function() { log.info("Database connection: reconnected") }
        )
        .on(
          "fullsetup",
          function() { log.info("Database connection: fullsetup") }
        )
        .on("all", function() { log.info("Database connection: all") } )
        .on("error", function() { log.crit("MongoDB connection: error:") } );
    } catch (error) {
      log.crit(error);
    }
  }
  async connect(username, password, dbname) {
    try {
      await mongoose.connect(
        `mongodb+srv://${username}:${password}@projectandromeda.fynyq5r.mongodb.net/${dbname}?retryWrites=true&w=majority`,
        {
          useNewUrlParser: true,
          useUnifiedTopology: true,
        }
      );
    } catch (error) {
      log.crit(error);
    }
  }

  async close() {
    try {
      await this.connection.close();
    } catch (error) {
      log.crit(error);
    }
  }
}

module.exports = new Database();
