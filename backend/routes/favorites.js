const express = require('express');
const Favorite = require('../models/Favorite');
const auth = require('../middleware/auth');
const router = express.Router();

// @route   GET /api/favorites
// @desc    Get user's favorites
router.get('/', auth, async (req, res) => {
  try {
    const { type } = req.query;
    const query = { userId: req.user._id };
    if (type) query.type = type;
    
    const favorites = await Favorite.find(query).sort({ createdAt: -1 });
    res.json(favorites);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   POST /api/favorites
// @desc    Add a favorite
router.post('/', auth, async (req, res) => {
  try {
    const { type, externalId, name, address, location, rating, imageUrl, metadata } = req.body;
    
    // Check if already favorited
    const existing = await Favorite.findOne({ userId: req.user._id, externalId, type });
    if (existing) {
      return res.status(400).json({ message: 'Already in favorites' });
    }

    const favorite = new Favorite({
      userId: req.user._id,
      type, externalId, name, address, location, rating, imageUrl, metadata
    });
    
    await favorite.save();
    res.status(201).json(favorite);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// @route   DELETE /api/favorites/:id
// @desc    Remove a favorite
router.delete('/:id', auth, async (req, res) => {
  try {
    const favorite = await Favorite.findOneAndDelete({ _id: req.params.id, userId: req.user._id });
    if (!favorite) {
      return res.status(404).json({ message: 'Favorite not found' });
    }
    res.json({ message: 'Removed from favorites' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
