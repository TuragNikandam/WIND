const mongoose = require("mongoose");
const { Schema } = mongoose;

const optionSchema = new Schema({
  text: {
    type: String,
    required: true,
    trim: true,
  },
  voteCount: {
    type: Number,
    default: 0,
  },
    votedUsers: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }]
});

const votingSchema = new Schema({
  question: {
    type: String,
    required: true,
    trim: true,
  },
  options: [optionSchema],
  multipleChoices: {
    type: Boolean,
    default: false,
  },  
  topic: {
    type: Schema.Types.ObjectId,
    ref: "Topic",
    required: true,
  },
  creationDate: {
    type: Date,
    default: Date.now,
  },
  expirationDate: {
    type: Date,
    required: true,
    index: true,
  },
});

const Voting = mongoose.model("Votings", votingSchema);

module.exports = Voting;
