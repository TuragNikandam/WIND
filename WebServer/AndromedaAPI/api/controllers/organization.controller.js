const Organization = require("../models/organization.model.js");
const log = require("../config/log.js");

exports.create = async (req, res) => {
  try {
    const organization = new Organization(req.body);
    const data = await organization.save();
    log.info(`Organization created: ${data}`);
    res.status(201).json({ created: data });
  } catch (error) {
    log.crit(error);
    res.status(500).json({
      message: error.message || "An unknown error occurred while creating the organization."
    });
  }
};

exports.findAll = async (req, res) => {
  try {
    const organization = await Organization.find();
    log.info("All organizations returned successfully.");
    res.status(200).send(organization);
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An unknown error occurred while getting all organizations."
    });
  }
};

exports.findOne = async (req, res) => {
  const organizationId = req.params.organizationId;

  try {
    const organization = await Organization.findById(organizationId);
    if (!organization) {
      log.warn(`Organization with id=${organizationId} not found.`);
      res.status(404).send({ message: `Organization with id=${organizationId} not found.` });
    } else {
      log.info(`Organization with id=${organizationId} returned successfully`);
      res.status(200).send(organization);
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error retrieving organization with id=${organizationId}.` });
  }
};

exports.update = async (req, res) => {
  if (!req.body) {
    log.warn("Update with empty body data failed");
    return res.status(400).send({ message: "Data to update cannot be empty!" });
  }

  const organizationId = req.params.organizationId;

  try {
    const updatedOrganization = await Organization.findByIdAndUpdate(organizationId, req.body, { new: true });
    if (!updatedOrganization) {
      log.warn(`Update for organization with id=${organizationId} not possible.`);
      res.status(404).send({ message: `Cannot update organization with id=${organizationId}.` });
    } else {
      log.info(`Organization with id=${organizationId} updated successfully. ${updatedOrganization}`);
      res.status(200).send({ message: "Organization was updated successfully." });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Error updating organization with id=${organizationId}.` });
  }
};

exports.delete = async (req, res) => {
  const organizationId = req.params.organizationId;

  try {
    const deletedOrganization = await Organization.findByIdAndRemove(organizationId);
    if (!deletedOrganization) {
      log.warn(`Delete organiztaion with id=${organizationId} not possible.`);
      res.status(404).send({ message: `Cannot delete organization with id=${organizationId}.` });
    } else {
      log.info(`Organiztaion with id=${organizationId} deleted successfully`);
      res.status(200).send({ message: "Organization was deleted successfully!" });
    }
  } catch (error) {
    log.crit(error);
    res.status(500).send({ message: `Could not organization party with id=${organizationId}.` });
  }
};

exports.deleteAll = async (req, res) => {
  try {
    const data = await Organization.deleteMany({});
    log.info(`deleted ${data.deletedCount} organizations.`);
    res.status(200).send({
      message: `${data.deletedCount} organizations were deleted successfully!`
    });
  } catch (error) {
    log.crit(error);
    res.status(500).send({
      message: error.message || "An error occurred while removing all organizations."
    });
  }
};
