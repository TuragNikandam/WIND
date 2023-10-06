const NewsArticle = require("../models/news.model.js");
const NewsArticleComment = require("../models/news.comment.model.js");
const log = require("../config/log.js");
const mongoose = require('mongoose');

exports.create = async (req, res) => {
  try {
    const newsArticle = new NewsArticle(req.body);
    const data = await newsArticle.save();
    log.info(`News article created: ${data}`);
    res.status(201).json({ created: data });
  } catch (error) {
    log.crit(error);
    res.status(500).json({
      message: error.message || "An unknown error occurred while creating the news article."
    });
  }
};

exports.findAll = async (req, res) => {
  try {
    const articles = await NewsArticle.find();

    log.info("All news articles returned successfully.");
    res.status(200).send(articles);
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An unknown error occurred while getting all news articles."
    });
  }
};

exports.findOne = async (req, res) => {
  const newsArticleId = req.params.newsArticleId;

  try {
    const article = await NewsArticle.findById(newsArticleId);
    if (!article) {
      log.warn(`News article with id=${newsArticleId} not found.`);
      res.status(404).send({ message: `News article with id=${newsArticleId} not found.` });
    } else {
      log.info(`News article with id=${newsArticleId} returned successfully`);
      res.status(200).send(article);
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error retrieving news article with id=${newsArticleId}.` });
  }
};

exports.update = async (req, res) => {
  if (!req.body) {
    log.warn("Update with empty body data failed");
    return res.status(400).send({ message: "Data to update cannot be empty!" });
  }

  const newsArticleId = req.params.newsArticleId;

  try {
    const updatedArticle = await NewsArticle.findByIdAndUpdate(newsArticleId, req.body, { new: true });
    if (!updatedArticle) {
      log.warn(`Update for news article with id=${newsArticleId} not possible.`);
      res.status(404).send({ message: `Cannot update news article with id=${newsArticleId}.` });
    } else {
      log.info(`News article with id=${newsArticleId} updated successfully. ${updatedArticle}`);
      res.status(200).send({ message: "News article was updated successfully." });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error updating news article with id=${newsArticleId}.` });
  }
};

exports.delete = async (req, res) => {
  const newsArticleId = req.params.newsArticleId;
  const session = await mongoose.startSession();

  try {
    session.startTransaction();

    // Delete corresponding comments
    await NewsArticleComment.deleteMany({ articleId: newsArticleId }, { session });

    // Delete news article
    const deletedArticle = await NewsArticle.findByIdAndRemove(newsArticleId, { session });

    await session.commitTransaction();

    if (!deletedArticle) {
      log.warn(`Delete news article with id=${newsArticleId} not possible.`);
      res.status(404).send({ message: `Cannot delete news article with id=${newsArticleId}.` });
    } else {
      log.info(`News article with id=${newsArticleId} deleted successfully`);
      res.status(200).send({ message: "News article was deleted successfully!" });
    }
  } catch (error) {
    await session.abortTransaction();
    log.crit(error);
    res.status(500).send({ message: `Could not delete news article with id=${newsArticleId}.` });
  }
  finally {
    session.endSession();
  }
};

exports.deleteAll = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    session.startTransaction();

    const deletedNewsArticle = await NewsArticle.deleteMany({}, session);
    const deletedComments = await NewsArticleComment.deleteMany({}, session);

    await session.commitTransaction();

    log.info(`Deleted ${deletedNewsArticle.deletedCount} news articles with ${deletedComments.deletedCount} corresponding comments.`);
    res.status(200).send({
      message: `${deletedNewsArticle.deletedCount} news articles and ${deletedComments.deletedCount} comments were deleted successfully!`
    });
  } catch (error) {
    await session.abortTransaction();
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while removing all news articles."
    });
  }
  finally {
    session.endSession();
  }
};
