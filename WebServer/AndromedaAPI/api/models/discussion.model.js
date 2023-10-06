const mongoose = require("mongoose");
const { Schema } = mongoose;

const discussionSchema = new Schema({
    title: {
       type: String,
       trim: true,
       required: true,
    },
    creationDate: {
        type: Date,
        default: Date.now
    },
    author: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    topic: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Topic',
        required: true,
    },
    postCount: {
        type: Number,
        default: 0
    }
});

module.exports = mongoose.model('Discussion', discussionSchema);