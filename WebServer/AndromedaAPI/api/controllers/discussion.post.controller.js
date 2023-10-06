const Discussion = require("../models/discussion.model.js");
const DiscussionPost = require("../models/discussion.post.model.js");
const log = require("../config/log.js");
const mongoose = require('mongoose');

exports.create = async (req, res) => {
  const discussionId = req.params.discussionId;
  const session = await mongoose.startSession();

  try {
    session.startTransaction();

    const discussionPost = new DiscussionPost({
      ...req.body,
      discussionId: discussionId,
    });

    const post = await discussionPost.save({ session });
    await Discussion.findByIdAndUpdate(discussionId,
      { $inc: { postCount: 1 }, },
      { session });

    await session.commitTransaction();

    log.info(`Discussion post created: ${post}`);
    res.status(201).json({ created: post });
  } catch (error) {
    await session.abortTransaction();
    log.crit(error);
    res.status(500).json({
      message:
        error.message ||
        "An unknown error occurred while creating the discussion post.",
    });
  }
  finally {
    session.endSession();
  }
};

exports.findAll = async (req, res) => {
  const discussionId = req.params.discussionId;

  try {
    const posts = await DiscussionPost.find({
      discussionId: discussionId,
    }).populate({   // Only fetch required data
      path: 'author',
      select: 'username party',
    });
    log.info("All discussion posts returned successfully.");
    res.status(200).send(posts);
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message:
        error.message ||
        "An unknown error occurred while getting all discussion posts.",
    });
  }
};

exports.findOne = async (req, res) => {
  const postId = req.params.postId;

  try {
    const postData = await DiscussionPost.findById(postId).populate({   // Only fetch required data
      path: 'author',
      select: 'username party',
    });
    if (!postData) {
      log.warn(`Discussion post with id=${postId} not found.`);
      res
        .status(404)
        .send({ message: `Discussion post with id=${postId} not found.` });
    } else {
      log.info(`Discussion post with id=${postId} returned successfully`);
      res.status(200).send(postData);
    }
  } catch (error) {
    log.crit(error);
    res
      .status(500)
      .send({ message: `Error retrieving discussion post with id=${postId}.` });
  }
};

exports.update = async (req, res) => {
  if (!req.body) {
    log.warn("Update with empty body data failed");
    return res.status(400).send({ message: "Data to update cannot be empty!" });
  }

  const postId = req.params.postId;

  try {
    const updatedPost = await DiscussionPost.findByIdAndUpdate(postId, req.body, {
      new: true,
    });
    if (!updatedPost) {
      log.warn(`Update for discussion post with id=${postId} not possible.`);
      res
        .status(404)
        .send({ message: `Cannot update discussion post with id=${postId}.` });
    } else {
      log.info(
        `Discussion post with id=${postId} updated successfully. ${updatedPost}`
      );
      res.status(200).send({ message: "Discussion post was updated successfully." });
    }
  } catch (error) {
    log.crit(error);
    res
      .status(500)
      .send({ message: `Error updating Discussion post with id=${postId}.` });
  }
};

exports.delete = async (req, res) => {
  const postId = req.params.postId;
  const discussionId = req.params.discussionId;

  const session = await mongoose.startSession();

  try {
    session.startTransaction();

    await Discussion.findByIdAndUpdate(discussionId,
      { $inc: { postCount: -1 } },
      { session });

    const deletedPost = await DiscussionPost.findByIdAndRemove(postId, { session });

    await session.commitTransaction();

    if (!deletedPost) {
      log.warn(`Delete discussion post with id=${postId} not possible.`);
      res
        .status(404)
        .send({ message: `Cannot delete discussion post with id=${postId}.` });
    } else {
      log.info(`Discussion post with id=${postId} deleted successfully`);
      res.status(200).send({ message: `Discussion post was deleted successfully!` });
    }
  } catch (error) {
    await session.abortTransaction();
    log.crit(error);
    res
      .status(500)
      .send({ message: `Could not delete discussion post with id=${postId}.` });
  }
  finally {
    session.endSession();
  }
};

exports.deleteAll = async (req, res) => {
  const discussionId = req.params.discussionId;
  const session = await mongoose.startSession();

  try {
    session.startTransaction();

    // Update corresponding discussion
    await Discussion.findByIdAndUpdate(discussionId,
      { $set: { postCount: 0 } },
      { session });

    // Delete all discussion posts
    const data = await DiscussionPost.deleteMany({ discussionId: discussionId });

    await session.commitTransaction();

    log.info(`Deleted ${data.deletedCount} discussion posts.`);
    res.status(200).send({
      message: `${data.deletedCount} discussion posts were deleted successfully!`,
    });
  } catch (error) {
    await session.abortTransaction();
    log.crit(error);
    res.status(500).send({
      message:
        error.message || "An error occurred while removing all discussion posts.",
    });
  }
  finally {
    session.endSession();
  }
};
