const mongoose = require('mongoose');

const journalEntrySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  tripId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Trip',
    required: false,
  },
  title: {
    type: String,
    default: '',
  },
  note: {
    type: String,
    default: '',
  },
  location: {
    lat: { type: Number },
    lng: { type: Number },
    name: { type: String, default: '' },
    country: { type: String, default: '' },
  },
  weather: {
    temp: { type: Number },
    description: { type: String, default: '' },
    icon: { type: String, default: '' },
  },
  photos: [{
    url: { type: String },
    caption: { type: String, default: '' },
  }],
  mood: {
    type: String,
    enum: ['Adventurous', 'Happy', 'Peaceful', 'Tired', 'Amazing', 'Sad', 'Neutral', 'amazing', 'happy', 'tired', 'sad', ''],
    default: '',
  },
  distanceTraveled: {
    type: Number,
    default: 0,
  },
}, {
  timestamps: true,
});

journalEntrySchema.index({ userId: 1, tripId: 1 });
journalEntrySchema.index({ createdAt: -1 });

module.exports = mongoose.model('JournalEntry', journalEntrySchema);
