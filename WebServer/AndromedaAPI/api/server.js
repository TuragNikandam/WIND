// Import builtin NodeJS modules to instantiate the service
require("dotenv").config();

const https = require("https"),
  fs = require("fs"),
  express = require("express"),
  crypto = require("crypto"),  
  bodyParser = require("body-parser"),
  database = require("./config/database.js"),
  log = require("./config/log.js"),
  app = express(),
  port = process.env.PORT,  

  //Routes
  user = require("./routes/user.route.js"),
  voting = require("./routes/voting.route.js"),
  topic = require("./routes/topic.route.js"),
  newsArticle = require("./routes/news.route.js"),  
  discussion = require("./routes/discussion.route.js"),
  unprotected = require("./routes/unprotected.route.js"),
  party = require("./routes/party.route.js"),
  organization = require("./routes/organization.route.js"),

  //Security
  helmet = require("helmet"),
  permissionMiddleware = require("./security/permissions.js"),
  corseMiddleware = require("./security/corse.js"),
  authorization = require("./security/tokenAuthorization.js");



process.env.JWT_SECRET = crypto.randomBytes(32).toString("hex");
database.connect(
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  process.env.DB_NAME
);

app.use(express.json());
app.use(bodyParser.json());

app.use(helmet());
app.use(corseMiddleware);
app.use("/", unprotected);
app.use(authorization);
app.use(permissionMiddleware);
app.use("/user", user);
app.use("/voting", voting);
app.use("/topic", topic);
app.use("/news", newsArticle);
app.use("/discussion", discussion);
app.use("/party", party);
app.use("/organization", organization);

app.use((err, req, res, next) => {
  if (process.env.NODE_ENV === "production") {
    // Only show error message in production environment
    res.status(500).json({
      error: true,
      message: err.message,
    });
  } else {
    // Show stack trace in other environments
    res.status(500).json({
      error: true,
      message: err.message,
      stack: err.stack,
    });
  }
});

https
  .createServer(
    {
      key: fs.readFileSync("../../HttpsConfig/AndromedaWebServerKey.pem"),
      cert: fs.readFileSync("../../HttpsConfig/AndromedaWebServerCERT.pem"),
    },
    app
  )
  .listen(port, () => {
    log.info(`server is runing at port ${process.env.PORT}`);
  });
