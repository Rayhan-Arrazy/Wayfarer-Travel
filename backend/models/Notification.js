const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    enum: ['trip_status', 'preparation_tip', 'emergency_alert', 'system'],
    default: 'system',
  },
  read: {
    type: Boolean,
    default: false,
  },
  link: {
    type: String, // route to navigate to
    default: '',
  },
}, {
  timestamps: true,
});

notificationSchema.index({ userId: 1, read: 1 });

module.exports = mongoose.model('Notification', notificationSchema);
