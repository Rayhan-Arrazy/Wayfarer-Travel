const mongoose = require('mongoose');

const budgetSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  tripId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Trip',
    required: false, // Optional if general budget
  },
  title: {
    type: String,
    required: true,
  },
  amount: {
    type: Number,
    required: true,
    default: 0,
  },
  currency: {
    type: String,
    default: 'USD',
  },
  expenses: [{
    title: { type: String, required: true },
    amount: { type: Number, required: true },
    date: { type: Date, default: Date.now },
    category: { type: String, default: 'General' },
  }],
}, {
  timestamps: true,
});

module.exports = mongoose.model('Budget', budgetSchema);
