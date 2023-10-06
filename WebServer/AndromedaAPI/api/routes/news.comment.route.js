const express = require("express");
const newsArticleCommentController = require("../controllers/news.comment.controller.js");
const router = express.Router({ mergeParams: true });

const rejectIsApprovedField = (req, res, next) => {
    if ('isApproved' in req.body) {
      return res.status(400).json({ error: "Rejected! The field 'isApproved' is not allowed to be set or updated via API-Request." });
    }
    next();
  };

router.post("/", rejectIsApprovedField, newsArticleCommentController.create);

router.get("/", newsArticleCommentController.findAll);
router.get("/:newsArticleCommentId", newsArticleCommentController.findOne);

router.put("/:newsArticleCommentId", rejectIsApprovedField, newsArticleCommentController.update);

router.delete("/:newsArticleCommentId", newsArticleCommentController.delete);
router.delete("/", newsArticleCommentController.deleteAll);

module.exports = router;