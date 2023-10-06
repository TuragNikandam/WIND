const mongoose = require("mongoose");
const uniqueValidator = require("mongoose-unique-validator");

let userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  password : {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },  
  is_guest: Boolean,
  party: {
    visible: Boolean,
    id: { 
      type: mongoose.Schema.Types.ObjectId,
      ref: "Party",    
      required: true,
    },
  },
  organizations: {
    visible: Boolean,
    ids: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Organization",
    }],
  },
  birthyear: {
    type: Number,
    required: true,
  },
  gender: {
    type: String,
    required: true,
    trim: true,
  },
  religion: {
    type: String,
    required: true,
    trim: true,
  },
  zip_code: {
    type: Number,
    required: true,
  },
});

userSchema.plugin(uniqueValidator);
const User = mongoose.model("User", userSchema);

module.exports = User;
