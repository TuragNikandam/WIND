const mongoose = require("mongoose");
const { Schema } = mongoose;

const organizationSchema = new Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  }, 
  shortName: {
    type: String,
    required: true,
    trim: true,
  },
  image: {
    url: {
      type: String,
      trim: true,
    },
    altText: {
      type: String,
      trim: true,
    },
  },
});

module.exports = mongoose.model("Organization", organizationSchema);
