const express = require("express");
const votingController = require("../controllers/voting.controller.js");
const router = express.Router();

router.post("/", votingController.create);
router.post("/:votingId", votingController.vote);
router.post("/:votingId/hasUserVoted", votingController.hasUserVoted);

router.get("/", votingController.findAll);
router.get("/closed", votingController.findAllClosed);
router.get("/active", votingController.findAllActive);
router.get("/:votingId", votingController.findOne);

router.put("/:votingId", votingController.update);

router.delete("/:votingId", votingController.delete);
router.delete("/", votingController.deleteAll);

module.exports = router;
