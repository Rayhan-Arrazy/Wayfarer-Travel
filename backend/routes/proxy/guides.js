const express = require('express');
const router = express.Router();
const CountryGuide = require('../../models/CountryGuide');

// @route   GET api/proxy/guides
// @desc    Get all country guides (stored in local DB)
// @access  Public
router.get('/', async (req, res) => {
  try {
    const guides = await CountryGuide.find().sort({ name: 1 });
    res.json(guides);
  } catch (err) {
    res.status(500).json({ message: 'Server Error' });
  }
});

module.exports = router;
