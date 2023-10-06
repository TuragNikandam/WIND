const express = require("express");
const newsArticleController = require("../controllers/news.controller.js");
const router = express.Router();
const commentsRouter = require('./news.comment.route.js');

router.use('/:newsArticleId/comment', commentsRouter);

router.post("/", newsArticleController.create);

router.get("/", newsArticleController.findAll);
router.get("/:newsArticleId", newsArticleController.findOne);

router.put("/:newsArticleId", newsArticleController.update);

router.delete("/:newsArticleId", newsArticleController.delete);
router.delete("/", newsArticleController.deleteAll);

module.exports = router;