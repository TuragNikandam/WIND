const Voting = require("../models/voting.model.js");
const log = require("../config/log.js");

exports.create = async (req, res) => {
  const voting = new Voting(req.body);

  try {
    const data = await voting.save();
    log.info(`Voting created: ${data}`);
    res.status(201).json({ created: data });
  } catch (error) {
    log.crit(error);
    res.status(500).json({
      message: error.message || "An unknown error occurred while creating the voting."
    });
  }
};

exports.findAll = async (req, res) => {
  try {
    const votings = await Voting.find();
    log.info("All Votings returned successfully.");
    res.status(200).send(votings);
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An unknown error occurred while getting all votings."
    });
  }
};

exports.findOne = async (req, res) => {
  const votingId = req.params.votingId;

  try {
    const voting = await Voting.findById(votingId);
    if (!voting) {
      log.warn(`Voting with id=${votingId} not found`);
      res.status(404).send({ message: `Voting with id=${votingId} not found` });
    } else {
      log.info(`Voting with id=${votingId} returned successfully`);
      res.status(200).send(voting);
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error retrieving voting with id=${votingId}.` });
  }
};

exports.update = async (req, res) => {
  if (!req.body) {
    log.warn("Update with empty body data failed");
    return res.status(400).send({ message: "Data to update cannot be empty!" });
  }

  const votingId = req.params.votingId;

  try {
    const updatedVoting = await Voting.findByIdAndUpdate(votingId, req.body, { new: true });
    if (!updatedVoting) {
      log.warn(`Update for voting with id=${votingId} not possible.`);
      res.status(404).send({ message: `Cannot update voting with id=${votingId}.` });
    } else {
      log.info(`Voting with id=${votingId} updated successfully. ${updatedVoting}`);
      res.status(200).send({ message: "Voting was updated successfully." });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error updating voting with id=${votingId}.` });
  }
};

exports.delete = async (req, res) => {
  const votingId = req.params.votingId;

  try {
    const deletedVoting = await Voting.findByIdAndRemove(votingId);
    if (!deletedVoting) {
      log.warn(`Delete voting with id=${votingId} not possible.`);
      res.status(404).send({ message: `Cannot delete voting with id=${votingId}.` });
    } else {
      log.info(`Voting with id=${votingId} deleted successfully`);
      res.status(200).send({ message: "Voting was deleted successfully!" });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Could not delete voting with id=${votingId}.` });
  }
};

exports.deleteAll = async (req, res) => {
  try {
    const data = await Voting.deleteMany({});
    log.info(`deleted ${data.deletedCount} votings.`);
    res.status(200).send({
      message: `${data.deletedCount} votings were deleted successfully!`
    });
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while removing all votings."
    });
  }
};

exports.vote = async (req, res) => {
  const votingId = req.params.votingId;
  const { optionIds, userId } = req.body;

  try {
    const voting = await Voting.findById(votingId);
    if (!voting) {
      log.warn(`Voting with id=${votingId} not found.`);
      return res.status(404).send({ message: "Voting not found" });
    }

    const currentDate = new Date();
    if (currentDate > voting.expiryDate) {
      return res.status(403).send({
        message: "Voting is already closed, no further votes accepted."
      });
    }

    for (let option of voting.options) {
      if (option.votedUsers.includes(userId)) {
        log.warn(`User ${userId} has already voted for voting ${votingId}`);
        return res.status(400).send({ message: `Only one vote per user allowed.` });
      }

      if (optionIds.includes(option._id.toString())) {
        option.voteCount += 1;
        option.votedUsers.push(userId);
      }
    }

    await voting.save();
    log.info(`Vote for user ${userId} with options ${optionIds} counted`);
    res.status(201).send({ message: "Vote counted" });
  } catch (error) {
    log.crit(error);
    res.status(500).json({
      message: error.message || "An unknown error occurred while voting."
    });
  }
};

exports.findAllActive = async (req, res) => {
  const currentDate = new Date();

  try {
    const activeVotings = await Voting.find({ expirationDate: { $gt: currentDate } });
    if (!activeVotings || activeVotings.length === 0) {
      log.warn("No active votings found");
      res.status(404).send({ message: "No active votings found" });
    } else {
      log.info(`All active votings returned successfully: (${activeVotings.length}).`);
      res.status(200).send(activeVotings);
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while retrieving active votings."
    });
  }
};

exports.findAllClosed = async (req, res) => {
  const currentDate = new Date();

  try {
    const closedVotings = await Voting.find({ expirationDate: { $lt: currentDate } });
    if (!closedVotings || closedVotings.length === 0) {
      log.warn("No closed votings found");
      res.status(404).send({ message: "No closed votings found" });
    } else {
      log.info(`All closed votings returned successfully: (${closedVotings.length}).`);
      res.status(200).send(closedVotings);
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while retrieving closed votings."
    });
  }
};

exports.hasUserVoted = async (req, res) => {
  const votingId = req.params.votingId;
  const userId = req.body.userId;

  try {
    const voting = await Voting.findById(votingId);
    if (!voting) {
      log.warn(`Voting with id=${votingId} not found.`);
      return res.status(404).send({ message: "Voting not found" });
    }

    let userHasVoted = false;
    for (let option of voting.options) {
      if (option.votedUsers.includes(userId)) {
        userHasVoted = true;
        break;
      }
    }

    if (userHasVoted) {
      log.info(`User ${userId} has already voted for voting ${votingId}`);
      return res.status(200).send({ message: "User has already voted", hasVoted: true });
    } else {
      log.info(`User ${userId} has not voted for voting ${votingId}`);
      return res.status(200).send({ message: "User has not voted", hasVoted: false });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An unknown error occurred while checking voting status."
    });
  }
};