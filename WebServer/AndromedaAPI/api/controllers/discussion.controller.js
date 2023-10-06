const Discussion = require("../models/discussion.model.js");
const DiscussionPost = require("../models/discussion.post.model.js");
const log = require("../config/log.js");
const mongoose = require('mongoose');

exports.create = async (req, res) => {
  try {
    const discussion = new Discussion(req.body);
    const data = await discussion.save();
    log.info(`Discussion created: ${data}`);
    res.status(201).json({ created: data });
  } catch (error) {
    log.crit(error);
    res.status(500).json({
      message: error.message || "An unknown error occurred while creating the discussion."
    });
  }
};

exports.findAll = async (req, res) => {
  try {
    const data = await Discussion.find().populate({   // Only fetch required data
      path: 'author',
      select: 'username',
    });
    log.info("All discussions returned successfully.");
    res.status(200).send(data);
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An unknown error occurred while getting all discussions."
    });
  }
};

exports.findOne = async (req, res) => {
  const discussionId = req.params.discussionId;

  try {
    const data = await Discussion.findById(discussionId).populate({   // Only fetch required data
      path: 'author',
      select: 'username',
    });
    if (!data) {
      log.warn(`Discussion with id=${discussionId} not found.`);
      res.status(404).send({ message: `Discussion with id=${discussionId} not found.` });
    } else {
      log.info(`Discussion with id=${discussionId} returned successfully`);
      res.status(200).send(data);
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error retrieving discussion with id=${discussionId}.` });
  }
};

exports.update = async (req, res) => {
  if (!req.body) {
    log.warn("Update with empty body data failed");
    return res.status(400).send({ message: "Data to update cannot be empty!" });
  }

  const discussionId = req.params.discussionId;
  
  try {
    const data = await Discussion.findByIdAndUpdate(discussionId, req.body, { new: true });
    if (!data) {
      log.warn(`Update for discussion with id=${discussionId} not possible.`);
      res.status(404).send({ message: `Cannot update discussion with id=${discussionId}.` });
    } else {
      log.info(`Discussion with id=${discussionId} updated successfully. ${data}`);
      res.status(200).send({ message: "Discussion was updated successfully." });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error updating discussion with id=${discussionId}.` });
  }
};

exports.delete = async (req, res) => {
  const discussionId = req.params.discussionId;
  const session = await mongoose.startSession();
  
  try {
    session.startTransaction();

    // Delete corresponding posts
    await DiscussionPost.deleteMany({ discussionId: discussionId }, { session });

    // Delete discussion
    const data = await Discussion.findByIdAndRemove(discussionId, { session });

    await session.commitTransaction();

    if (!data) {
      log.warn(`Delete discussion with id=${discussionId} not possible.`);
      res.status(404).send({ message: `Cannot delete discussion with id=${discussionId}.` });
    } else {
      log.info(`Discussion with id=${discussionId} deleted successfully`);
      res.status(200).send({ message: "Discussion was deleted successfully!" });
    }
  } catch (error) {
    await session.abortTransaction();
    log.crit(error);
    res.status(500).send({ message: `Could not delete discussion with id=${discussionId}.` });
  }
  finally {
    session.endSession();
  }
};

exports.deleteAll = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    session.startTransaction();

    const deletedDiscussions = await Discussion.deleteMany({}, session);
    const deletedDiscussionPosts = await DiscussionPost.deleteMany({}, session);

    await session.commitTransaction();

    log.info(`Deleted ${deletedDiscussions.deletedCount} discussions with ${deletedDiscussionPosts.deletedCount} corresponding posts.`);
    res.status(200).send({
      message: `${deletedDiscussions.deletedCount} discussions and ${deletedDiscussionPosts.deletedCount} posts were deleted successfully!`
    });
  } catch (error) {
    await session.abortTransaction();
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while removing all discussions."
    });
  }
  finally {
    session.endSession();
  }
};
