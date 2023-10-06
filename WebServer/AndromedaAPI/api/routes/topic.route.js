const express = require("express");
const topicController = require("../controllers/topic.controller.js");
const router = express.Router();

router.post("/", topicController.create);

router.get("/", topicController.findAll);
router.get("/:topicId", topicController.findOne);

router.put("/:topicId", topicController.update);

router.delete("/:topicId", topicController.delete);
router.delete("/", topicController.deleteAll);

module.exports = router;
