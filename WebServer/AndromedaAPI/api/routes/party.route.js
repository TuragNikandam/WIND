const express = require("express");
const partyController = require("../controllers/party.controller.js");
const router = express.Router();

router.post("/", partyController.create);

router.get("/", partyController.findAll);
router.get("/:partyId", partyController.findOne);

router.put("/:partyId", partyController.update);

router.delete("/:partyId", partyController.delete);
router.delete("/", partyController.deleteAll);

module.exports = router;