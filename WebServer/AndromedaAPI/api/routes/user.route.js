const express = require("express");
const userController = require("../controllers/user.controller.js");
const router = express.Router();

router.post("/logout", userController.logout)

router.get("/", userController.findAll);
router.get("/current", userController.findCurrent);
router.get("/:userId", userController.findOne);

router.put("/:userId", userController.update);


router.delete("/guests", userController.deleteAllGuests);
router.delete("/:userId", userController.delete);
router.delete("/", userController.deleteAll);

module.exports = router;
