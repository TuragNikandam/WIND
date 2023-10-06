const express = require("express");
const discussionPostController = require("../controllers/discussion.post.controller.js");
const router = express.Router({ mergeParams: true });

router.post("/", discussionPostController.create);

router.get("/", discussionPostController.findAll);
router.get("/:postId", discussionPostController.findOne);

router.put("/:postId", discussionPostController.update);

router.delete("/:postId", discussionPostController.delete);
router.delete("/", discussionPostController.deleteAll);

module.exports = router;