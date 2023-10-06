const express = require("express");
const userController = require("../controllers/user.controller.js");
const organizationController = require("../controllers/organization.controller.js")
const partyController = require("../controllers/party.controller.js")
const topicController = require("../controllers/topic.controller.js")
const router = express.Router();

router.post("/register", userController.create);
router.post("/register/checkUsername", userController.checkUsernameExists);
router.post("/register/checkEmail", userController.checkEmailExists);
router.post("/login", userController.login);

router.get("/data/organization", organizationController.findAll);
router.get("/data/party", partyController.findAll);
router.get("/data/topic", topicController.findAll);

router.get("/guest/login", userController.loginAsGuest);

module.exports = router;