const Topic = require("../models/topic.model.js");
const log = require("../config/log.js");

exports.create = async (req, res) => {
  try {
    const topic = new Topic(req.body);
    const data = await topic.save();
    log.info(`Topic created: ${data}`);
    res.status(201).json({ created: data });
  } catch (error) {
    log.crit(error);
    res.status(500).json({
      message: error.message || "An unknown error occurred while creating the topic."
    });
  }
};

exports.findAll = async (req, res) => {
  try {
    const topics = await Topic.find();
    log.info("All topics returned successfully.");
    res.status(200).send(topics);
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An unknown error occurred while getting all topics."
    });
  }
};

exports.findOne = async (req, res) => {
  const topicId = req.params.topicId;

  try {
    const topic = await Topic.findById(topicId);
    if (!topic) {
      log.warn(`Topic with id=${topicId} not found.`);
      res.status(404).send({ message: `Topic with id=${topicId} not found.` });
    } else {
      log.info(`Topic with id=${topicId} returned successfully`);
      res.status(200).send(topic);
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error retrieving topic with id=${topicId}.` });
  }
};

exports.update = async (req, res) => {
  if (!req.body) {
    log.warn("Update with empty body data failed");
    return res.status(400).send({ message: "Data to update cannot be empty!" });
  }

  const topicId = req.params.topicId;

  try {
    const updatedTopic = await Topic.findByIdAndUpdate(topicId, req.body, { new: true });
    if (!updatedTopic) {
      log.warn(`Update for topic with id=${topicId} not possible.`);
      res.status(404).send({ message: `Cannot update topic with id=${topicId}.` });
    } else {
      log.info(`Topic with id=${topicId} updated successfully. ${updatedTopic}`);
      res.status(200).send({ message: "Topic was updated successfully." });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error updating topic with id=${topicId}.` });
  }
};

exports.delete = async (req, res) => {
  const topicId = req.params.topicId;

  try {
    const deletedTopic = await Topic.findByIdAndRemove(topicId);
    if (!deletedTopic) {
      log.warn(`Delete topic with id=${topicId} not possible.`);
      res.status(404).send({ message: `Cannot delete topic with id=${topicId}.` });
    } else {
      log.info(`Topic with id=${topicId} deleted successfully`);
      res.status(200).send({ message: "Topic was deleted successfully!" });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Could not delete topic with id=${topicId}.` });
  }
};

exports.deleteAll = async (req, res) => {
  try {
    const data = await Topic.deleteMany({});
    log.info(`deleted ${data.deletedCount} topics.`);
    res.status(200).send({
      message: `${data.deletedCount} topics were deleted successfully!`
    });
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while removing all topics."
    });
  }
};
