const express = require('express');
const JournalEntry = require('../models/JournalEntry');
const Trip = require('../models/Trip');
const User = require('../models/User');
const auth = require('../middleware/auth');
const router = express.Router();

// @route   GET /api/journal
// @desc    Get all journal entries for current user
router.get('/', auth, async (req, res) => {
  try {
    const { tripId } = req.query;
    const query = { userId: req.user._id };
    if (tripId) query.tripId = tripId;
    
    const entries = await JournalEntry.find(query)
      .sort({ createdAt: -1 })
      .populate('tripId', 'destination countryName');
    res.json(entries);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   POST /api/journal
// @desc    Create a journal entry
router.post('/', auth, async (req, res) => {
  try {
    const { tripId, title, note, location, weather, photos, mood } = req.body;

    // Verify trip belongs to user if tripId is provided
    if (tripId && tripId.trim() !== '') {
      const trip = await Trip.findOne({ _id: tripId, userId: req.user._id });
      if (!trip) {
        return res.status(404).json({ message: 'Trip not found' });
      }
    }

    const entry = new JournalEntry({
      userId: req.user._id,
      tripId: (tripId && tripId.trim() !== '') ? tripId : null,
      title: title || '',
      note: note || '',
      location: location || {},
      weather: weather || {},
      photos: photos || [],
      mood: mood || '',
    });

    await entry.save();
    res.status(201).json(entry);
  } catch (error) {
    console.error('Create journal error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// @route   GET /api/journal/stats
// @desc    Get travel stats for current user
router.get('/stats', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const trips = await Trip.find({ userId: req.user._id, status: 'completed' });
    const entries = await JournalEntry.find({ userId: req.user._id });

    // Calculate total days traveled
    let totalDays = 0;
    trips.forEach(trip => {
      const start = new Date(trip.startDate);
      const end = new Date(trip.endDate);
      totalDays += Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    });

    // Get unique countries
    const countries = [...new Set(trips.map(t => t.countryCode))];

    // Total distance from journal entries
    const totalDistance = entries.reduce((sum, e) => sum + (e.distanceTraveled || 0), 0);

    res.json({
      totalTrips: trips.length,
      totalDays,
      countriesVisited: countries.length,
      countries,
      totalEntries: entries.length,
      totalDistance: Math.round(totalDistance),
      visitedCountries: user.visitedCountries || [],
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   PUT /api/journal/:id
// @desc    Update a journal entry
router.put('/:id', auth, async (req, res) => {
  try {
    // Sanitize tripId if it's an empty string to avoid CastError
    if (req.body.tripId === '' || req.body.tripId === 'null') {
      req.body.tripId = null;
    }

    const entry = await JournalEntry.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      { $set: req.body },
      { new: true }
    );
    if (!entry) {
      return res.status(404).json({ message: 'Entry not found' });
    }
    res.json(entry);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/journal/:id
// @desc    Delete a journal entry
router.delete('/:id', auth, async (req, res) => {
  try {
    const entry = await JournalEntry.findOneAndDelete({ _id: req.params.id, userId: req.user._id });
    if (!entry) {
      return res.status(404).json({ message: 'Entry not found' });
    }
    res.json({ message: 'Entry deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
