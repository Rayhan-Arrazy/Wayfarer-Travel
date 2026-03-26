const mongoose = require('mongoose');

const countryGuideSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  countryCode: {
    type: String,
    required: true,
    uppercase: true
  },
  flagUrl: String,
  coverImage: String,
  description: String,
  tips: [{
    type: String
  }],
  bestTimeToVisit: String,
  language: String,
  currency: String,
  topCities: [{
    name: String,
    description: String,
    image: String
  }],
  featured: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('CountryGuide', countryGuideSchema);
