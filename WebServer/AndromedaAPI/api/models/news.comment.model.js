const mongoose = require("mongoose");
const { Schema } = mongoose;

const CommentSchema = new Schema({
  content: {
    type: String,
    required: true,
  },
  links: {
    type: String,
    required: true,
  },
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  isApproved: {
    type: Boolean,
    default: false,
  },
  date: {
    type: Date,
    default: Date.now,
  },
  articleId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'News',
    required: true,
  },
});

module.exports = mongoose.model("NewsComment", CommentSchema);
