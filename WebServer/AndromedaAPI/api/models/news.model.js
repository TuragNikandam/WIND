const mongoose = require("mongoose");
const { Schema } = mongoose;

const newsArticleSchema = new Schema({
  headline: {
    type: String,
    required: true,
    trim: true,
  },
  image: {
    url: {
      type: String,
      required: true,
      trim: true,
    },
    altText: {
      type: String,
      trim: true,
    },
  },
  content: {
    type: String,
    required: true,
    trim: true,
  },
  topic: {
    type: Schema.Types.ObjectId,
    ref: "Topic",
    required: true,
  },
  sources: [{
    type: String,
    required: true,
  }],
  createdBy: {
    type: Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  creationDate: {
    type: Date,
    default: Date.now,
  },
  viewCount: {
    type: Number,
    default: 0,
  },
});

module.exports = mongoose.model("News", newsArticleSchema);
