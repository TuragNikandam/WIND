const mongoose = require('mongoose');
const { Schema } = mongoose;

const discussionPostSchema = new Schema({
    content: {
        type: String,
        trim: true,
        required: true,
    },
    author: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    creationDate: {
        type: Date,
        default: Date.now
    },
    discussionId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Discussion'
    },
});

module.exports = mongoose.model('DiscussionPost', discussionPostSchema);