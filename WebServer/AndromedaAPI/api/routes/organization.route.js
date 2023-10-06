const express = require("express");
const organizationController = require("../controllers/organization.controller.js");
const router = express.Router();

router.post("/", organizationController.create);

router.get("/", organizationController.findAll);
router.get("/:organizationId", organizationController.findOne);

router.put("/:organizationId", organizationController.update);

router.delete("/:organizationId", organizationController.delete);
router.delete("/", organizationController.deleteAll);

module.exports = router;