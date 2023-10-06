const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const log = require("../config/log");
const database = require("../config/database.js");

async function authenticate(req, res, next) {
  const token = req.header("Authorization")
    ? req.header("Authorization").replace("Bearer ", "")
    : null;

  if (!token || token.trim() === "") {
    return res.status(401).send("Access denied. No token provided.");
  }

  try {
    const isRevoked = await isTokenRevoked(token);
    if (!isRevoked) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      log.info(`Authorization successful`);
      next(); // Weiter zur nächsten Middleware oder Route
    } else {
      log.info(`Token is revoked, access denied.`);
      return res.status(401).send("Access denied. Token is revoked.");
    }
  } catch (error) {
    log.crit(error);
    res.status(401).send("Invalid token");
  }
}

function isTokenRevoked(token) {
  return new Promise((resolve, reject) => {
    if (!token || token.trim() === "") {
      resolve(false);
      return;
    }

    // Compute a SHA256 of the token
    const hash = crypto.createHash("sha256");
    hash.update(token);
    const jwtTokenDigestInHex = hash.digest("hex").toUpperCase();

    // Search token digest in HEX in DB
    let connection = database.connection;
    const collection = connection.collection("revoked_token");
    collection.findOne(
      { token: jwtTokenDigestInHex },
      (error, result) => {
        if (error) reject(error);
        resolve(result !== null);
      }
    );
  });
}

module.exports = authenticate;
