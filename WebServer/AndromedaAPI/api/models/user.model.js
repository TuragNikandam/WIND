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
  role: {
    type: String,
    enum: ['user', 'guest', 'admin'], // Enum to ensure only valid roles are set
    default: 'user'
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },  
  isGuest: Boolean,
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
  validate: [organizationLimit, 'Exceeds the limit of 5 organizations that a user can be a part of.']
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
  zipCode: {
    type: Number,
    required: true,
  },
  personalInformationVisible : Boolean,
});

function organizationLimit(list) {
  return list.length <= 5;
}

userSchema.plugin(uniqueValidator);
const User = mongoose.model("User", userSchema);

module.exports = User;
