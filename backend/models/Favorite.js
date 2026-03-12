const mongoose = require('mongoose');

const favoriteSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  type: {
    type: String,
    enum: ['hotel', 'restaurant', 'attraction', 'place'],
    required: true,
  },
  externalId: {
    type: String,
    default: '',
  },
  name: {
    type: String,
    required: true,
  },
  address: {
    type: String,
    default: '',
  },
  location: {
    lat: { type: Number },
    lng: { type: Number },
  },
  rating: {
    type: Number,
    default: 0,
  },
  imageUrl: {
    type: String,
    default: '',
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {},
  },
}, {
  timestamps: true,
});

favoriteSchema.index({ userId: 1, type: 1 });

module.exports = mongoose.model('Favorite', favoriteSchema);
