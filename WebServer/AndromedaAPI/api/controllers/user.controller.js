const User = require("../models/user.model.js");
const log = require("../config/log.js");
const bcrypt = require("bcrypt");
require("dotenv").config();
const jwt = require("jsonwebtoken");
const database = require("../config/database.js");
const crypto = require("crypto");

async function usernameExists(username) {
  const user = await User.findOne({ username });
  return !!user;
}

// Utility function to check if an email exists
async function emailExists(email) {
  const user = await User.findOne({ email });
  return !!user;
}


exports.create = async (req, res) => {
  try {
    const hashedPassword = await bcrypt.hash(req.body.password, 10);
    const user = new User({
      ...req.body,
      password: hashedPassword,
    });

    const data = await user.save();
    log.info(`User created: ${data}`);
    res.status(201).json({ created: data });
  } catch (error) {
    log.crit(error);
    res.status(500).json({
      message:
        error.message || "An unknown error occurred while creating the user.",
    });
  }
};

exports.findAll = async (req, res) => {
  try {
    const users = await User.find();
    log.info("All users returned successfully.");
    res.send(users);
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message:
        error.message || "An unknown error occurred while getting all users.",
    });
  }
};

exports.findCurrent = async (req, res) => {
  const token = req.header("Authorization")
    ? req.header("Authorization").replace("Bearer ", "")
    : null;

  if (!token || token.trim() === "") {
    log.warn(
      `Searching for current user failed because of invalid or empty token.`
    );
    return res.status(400).send("Invalid token provided.");
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.params.userId = decoded._id;
    await exports.findOne(req, res);
  } catch (error) {
    log.warn(
      `Searching for current user failed because of a problem while decoding the token.`
    );
    return res.status(400).send("Error decoding given token.");
  }
};

exports.findOne = async (req, res) => {
  const userId = req.params.userId;

  try {
    const user = await User.findById(userId);
    if (!user) {
      log.warn(`User with id=${userId} not found`);
      res.status(404).send({ message: `User with id=${userId} not found` });
    } else {
      log.info(`User with id=${userId} returned successfully`);
      res.send(user);
    }
  } catch (error) {
    log.crit(error);
    res
      .status(500)
      .send({ message: `Error retrieving User with id=${userId}` });
  }
};

//TODO: do not allow password updates
exports.update = async (req, res) => {
  if (!req.body) {
    log.warn("Update user failed because of empty body data.");
    return res.status(400).send({ message: "Data to update cannot be empty!" });
  }

  const userId = req.params.userId;

  try {
    const updatedUser = await User.findByIdAndUpdate(userId, req.body, {
      new: true,
    });
    if (!updatedUser) {
      log.warn(`Update for user with id=${userId} not possible.`);
      res.status(404).send({ message: `User with id=${userId} not found.` });
    } else {
      log.info(`User with id=${userId} updated successfully. ${updatedUser}`);
      res.status(200).send({ message: "User was updated successfully." });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error updating User with id=${userId}.` });
  }
};

exports.delete = async (req, res) => {
  const userId = req.params.userId;

  try {
    const deletedUser = await User.findByIdAndRemove(userId);
    if (!deletedUser) {
      log.warn(`Delete user with id=${userId} not possible.`);
      res
        .status(404)
        .send({ message: `Cannot delete User with id=${userId}.` });
    } else {
      log.info(`User with id=${userId} deleted successfully`);
      res.status(200).send({ message: "User was deleted successfully!" });
    }
  } catch (error) {
    log.crit(error);
    res
      .status(500)
      .send({ message: `Could not delete User with id=${userId}.` });
  }
};

exports.deleteAll = async (req, res) => {
  try {
    const data = await User.deleteMany({});
    log.info(`deleted ${data.deletedCount} users.`);
    res.status(200).send({
      message: `${data.deletedCount} Users were deleted successfully!`,
    });
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while removing all users.",
    });
  }
};

exports.deleteAllGuests = async (req, res) => {
  try {
    // Delete users where isGuest is true
    const data = await User.deleteMany({ is_guest: true });
    
    log.info(`Deleted ${data.deletedCount} guest users.`);
    
    res.status(200).send({
      message: `${data.deletedCount} Guest users were deleted successfully!`,
    });
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while removing guest users.",
    });
  }
}

exports.login = async (req, res) => {
  try {
    const user = await User.findOne({ username: req.body.username });
    if (!user) {
      log.warn(`User with username=${req.body.username} not found.`);
      return res.status(400).send({ message: `User not found.` });
    }

    if (user.isGuest) {
      log.crit('Login with guest account not allowed.');
      return res.status(400).send({ message: `Login as guest denied` });
    }

    const validPassword = await bcrypt.compare(
      req.body.password,
      user.password
    );
    if (!validPassword) {
      log.warn(`Invalid password for username=${user.username}`);
      return res.status(400).send({ message: `Invalid password` });
    }   

    const token = jwt.sign({ _id: user._id, role: 'user' }, process.env.JWT_SECRET, {
      expiresIn: "3h",
    });
    log.info(`Token for user created.`);
       res.status(200).json({ token });
  } catch (error) {
    log.crit(error);
    res.status(500).send("Error logging in");
  }
};

exports.logout = async (req, res) => {
  const token = req.header("Authorization")
    ? req.header("Authorization").replace("Bearer ", "")
    : null;

  if (!token || token.trim() === "") {
    log.warn(`Logout attempt with invalid or empty token.`);
    return res.status(400).send("Invalid token provided.");
  }

  // Compute a SHA256 of the token
  const hash = crypto.createHash("sha256");
  hash.update(token);
  const jwtTokenDigestInHex = hash.digest("hex").toUpperCase();

  // Check if the token digest in HEX is already in the DB and add it if it is absent
  let connection = database.connection;
  const collection = connection.collection("revoked_token");

  collection.findOne(
    { token: jwtTokenDigestInHex }, 
    async (error, result) => {
      if (error) {
        log.crit(error);
        return res.status(500).send("Error checking the token.");
      }

      if (!result) {
        try {
          const insertResult = await collection.insertOne({
            token: jwtTokenDigestInHex,
          });
          if (insertResult.acknowledged) {
            log.info(`Token successfully revoked.`);
            res.status(200).send("Successfully logged out.");
          } else {
            log.warn(`Error revoking the token. Insert was not acknowledged.`);
            res.status(500).send("Error while logging out.");
          }
        } catch (err) {
          log.crit(err);
          res.status(500).send("Error while logging out.");
        }
      } else {
        log.info(`Logout attempt with a token that is already revoked.`);
        // Status 409 - Conflict
        res.status(409).send("Already logged out.");
      }
    }
  );
};

exports.checkUsernameExists = async (req, res) => {
  try {
    const { username } = req.body;
    if (!username) {
      log.warn("Username is required");
      return res.status(400).json({ message: "Username is required" });
    }

    if (await usernameExists(username)) {
      log.info("Username already exists");
      return res.status(409).json({ message: "Username already exists" });
    }

    log.info("Username is available");
    res.status(200).json({ message: "Username is available" });
  } catch (error) {
    log.crit(error);
    res.status(500).json({ message: "Internal Server Error" });
  }
};

exports.checkEmailExists = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      log.warn("Email is required");
      return res.status(400).json({ message: "Email is required" });
    }

    if (await emailExists(email)) {
      log.info("Email already exists");
      return res.status(409).json({ message: "Email already exists" });
    }

    log.info("Email is available");
    res.status(200).json({ message: "Email is available" });
  } catch (error) {
    log.crit(error);
    res.status(500).json({ message: "Internal Server Error" });
  }
};

exports.loginAsGuest = async (req, res) => {

  const username = await getUniqueUsername();
  const email = await getUniqueEmail();
  try {
        // Create the new user object
        const user = new User({
          username,
          password: "guest", // Default value
          email,
          is_guest: true,
          party: {
            visible: false,
            id : "64ce483430b6a5ec478704df",
          },
          organizations: { visible: false, ids: [] }, // Default values
          birthyear: 0, // Default value
          gender: "guest", // Default value
          religion: "guest", // Default value
          zip_code: 0, // Default value
        });

    const data = await user.save();
    log.info(`Guest created: ${data}`);
    const token = jwt.sign({ _id: user._id, role: 'guest' }, process.env.JWT_SECRET, {
      expiresIn: "3h",
    });
    log.info(`Token for guest created.`);
    res.status(200).json({ token });
  } catch (error) {
    log.crit(error);
    res.status(500).json({
      message:
        error.message || "An unknown error occurred while creating the guest.",
    });
  }

  function generateRandomUsername() {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let username = 'guest-';
    for (let i = 0; i < 15; i++) {
      username += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return username;
  }
  
  // Function to generate a random email
  function generateRandomEmail() {
    const domain = ['gmail.com', 'yahoo.com', 'outlook.com'];
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let email = 'guest-';
    for (let i = 0; i < 15; i++) {
      email += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    email += '@';
    email += domain[Math.floor(Math.random() * domain.length)];
    return email;
  }

  async function getUniqueUsername() {
    let username;
    do {
      username = generateRandomUsername();
    } while (await usernameExists(username));
    return username;
  }
  
  async function getUniqueEmail() {
    let email;
    do {
      email = generateRandomEmail();
    } while (await emailExists(email));
    return email;
  }


}
