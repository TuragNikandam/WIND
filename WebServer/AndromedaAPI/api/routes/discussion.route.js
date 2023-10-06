const express = require("express");
const discussionController = require("../controllers/discussion.controller.js");
const router = express.Router();
const dicussionPostRouter = require('./discussion.post.route.js');

router.use('/:discussionId/post', dicussionPostRouter);

router.post("/", discussionController.create);

router.get("/", discussionController.findAll);
router.get("/:discussionId", discussionController.findOne);

router.put("/:discussionId", discussionController.update);

router.delete("/:discussionId", discussionController.delete);
router.delete("/", discussionController.deleteAll);

module.exports = router;
