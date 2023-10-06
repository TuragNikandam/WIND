const NewsArticleComment = require("../models/news.comment.model.js");
const log = require("../config/log.js");

exports.create = async (req, res) => {
    try {
        const newsArticleId = req.params.newsArticleId;

        const newsArticleComment = new NewsArticleComment({
            ...req.body,
            articleId: newsArticleId,
        });

        const comment = await newsArticleComment.save();

        log.info(`News article comment created: ${comment}`);
        res.status(201).json({ created: comment });
    }
    catch (error) {
        log.crit(error);
        res.status(500).json({
            message: error.message || "An unknown error occurred while creating the comment of a news article."
        });
    }
};

exports.findAll = async (req, res) => {
    try {
        const newsArticleId = req.params.newsArticleId;
        const comments = await NewsArticleComment.find({ 
            articleId: newsArticleId,
            isApproved: true    // Only approved
        }).populate({
            path: 'author',
            select: 'username'  // Only fetch required data
        });

        log.info("All news article comments returned successfully.");
        res.status(200).send(comments);
    } catch (error) {
        log.crit(error);
        res.status(500).send({
            message: error.message || "An unknown error occurred while retrieving the comments."
        });
    }
};

exports.findOne = async (req, res) => {
    const newsArticleCommentId = req.params.newsArticleCommentId;

    try {
        const comment = await NewsArticleComment.findById(newsArticleCommentId).populate({
            path: 'author',
            select: 'username' // Only fetch required data
        });

        if (!comment) {
            log.warn(`News article comment with id=${newsArticleCommentId} not found.`);
            res.status(404).send({ message: `News article with id=${newsArticleCommentId} not found.` });
        } else if (!comment.isApproved) {
            log.warn(`News article comment with id=${newsArticleCommentId} is not approved.`);
            res.status(403).send({ message: `News article comment with id=${newsArticleCommentId} is not approved.` });
        } else {
            log.info(`News article comment with id=${newsArticleCommentId} returned successfully`);
            res.status(200).send(comment);
        }
    } catch (error) {
        log.crit(error);
        res.status(500).send({ message: `Error retrieving news article comment with id=${newsArticleCommentId}.` });
    }
};

exports.update = async (req, res) => {
    if (!req.body) {
        log.warn("Update with empty body data failed");
        return res.status(400).send({ message: "Data to update cannot be empty!" });
    }

    const newsArticleCommentId = req.params.newsArticleCommentId;

    try {
        const updatedComment = await NewsArticleComment.findByIdAndUpdate(newsArticleCommentId, req.body, { new: true });
        if (!updatedComment) {
            log.warn(`Update for news article comment with id=${newsArticleCommentId} not possible.`);
            res.status(404).send({ message: `Cannot update news article comment with id=${newsArticleCommentId}.` });
        } else {
            log.info(`News article comment with id=${newsArticleCommentId} updated successfully. ${newsArticleCommentId}`);
            res.status(200).send({ message: "News article comment was updated successfully." });
        }
    } catch (error) {
        log.crit(error);
        res.status(500).send({ message: `Error updating news article comment with id=${newsArticleCommentId}.` });
    }
};

exports.delete = async (req, res) => {
    const deletedCommentId = req.params.newsArticleCommentId;

    try {
        const deletedComment = await NewsArticleComment.findByIdAndRemove(deletedCommentId);

        if (!deletedComment) {
            log.warn(`Delete news article comment with id=${deletedCommentId} not possible.`);
            res.status(404).send({ message: `Cannot delete news article comment with id=${deletedCommentId}.` });
        } else {
            log.info(`News article comment with id=${deletedCommentId} deleted successfully`);
            res.status(200).send({ message: "News article comment was deleted successfully!" });
        }
    } catch (error) {
        log.crit(error);
        res.status(500).send({ message: `Could not delete news article comment with id=${deletedCommentId}.` });
    }
};

exports.deleteAll = async (req, res) => {
    const newsArticleId = req.params.newsArticleId;
    try {
        const data = await NewsArticleComment.deleteMany({newsArticleId : newsArticleId});

        log.info(`Deleted ${data.deletedCount} news article comments.`);
        res.status(200).send({
            message: `${data.deletedCount} news article comments were deleted successfully!`
        });
    } catch (error) {
        log.crit(error);
        res.status(500).send({
            message: error.message || "An error occurred while removing all news article comments."
        });
    }
};
