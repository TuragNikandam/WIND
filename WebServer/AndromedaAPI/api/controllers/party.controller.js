const Party = require("../models/party.model.js");
const log = require("../config/log.js");

exports.create = async (req, res) => {
  try {
    const party = new Party(req.body);
    const data = await party.save();
    log.info(`Party created: ${data}`);
    res.status(201).json({ created: data });
  } catch (error) {
    log.crit(error);
    res.status(500).json({
      message: error.message || "An unknown error occurred while creating the party."
    });
  }
};

exports.findAll = async (req, res) => {
  try {
    const partys = await Party.find();
    log.info("All partys returned successfully.");
    res.status(200).send(partys);
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An unknown error occurred while getting all partys."
    });
  }
};

exports.findOne = async (req, res) => {
  const partyId = req.params.partyId;

  try {
    const party = await Party.findById(partyId);
    if (!party) {
      log.warn(`Party with id=${partyId} not found.`);
      res.status(404).send({ message: `Party with id=${partyId} not found.` });
    } else {
      log.info(`Party with id=${partyId} returned successfully`);
      res.status(200).send(party);
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error retrieving party with id=${partyId}.` });
  }
};

exports.update = async (req, res) => {
  if (!req.body) {
    log.warn("Update with empty body data failed");
    return res.status(400).send({ message: "Data to update cannot be empty!" });
  }

  const partyId = req.params.partyId;

  try {
    const updatedParty = await Party.findByIdAndUpdate(partyId, req.body, { new: true });
    if (!updatedParty) {
      log.warn(`Update for party with id=${partyId} not possible.`);
      res.status(404).send({ message: `Cannot update party with id=${partyId}.` });
    } else {
      log.info(`Party with id=${partyId} updated successfully. ${updatedParty}`);
      res.status(200).send({ message: "Party was updated successfully." });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error updating party with id=${partyId}.` });
  }
};

exports.delete = async (req, res) => {
  const partId = req.params.partyId;

  try {
    const deletedParty = await Party.findByIdAndRemove(partId);
    if (!deletedParty) {
      log.warn(`Delete party with id=${partId} not possible.`);
      res.status(404).send({ message: `Cannot delete party with id=${partId}.` });
    } else {
      log.info(`Party with id=${partId} deleted successfully`);
      res.status(200).send({ message: "Party was deleted successfully!" });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Could not delete party with id=${partId}.` });
  }
};

exports.deleteAll = async (req, res) => {
  try {
    const data = await Party.deleteMany({});
    log.info(`deleted ${data.deletedCount} partys.`);
    res.status(200).send({
      message: `${data.deletedCount} partys were deleted successfully!`
    });
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while removing all partys."
    });
  }
};
