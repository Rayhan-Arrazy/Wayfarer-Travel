const express = require('express');
const Planning = require('../models/Planning');
const auth = require('../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/planning
// @desc    Get all planning entries for current user
router.get('/', auth, async (req, res) => {
  try {
    const { status } = req.query;
    const query = { userId: req.user._id };
    if (status) query.status = status;
    
    // Auto-update planning statuses based on dates
    const now = new Date();
    await Planning.updateMany(
      { userId: req.user._id, status: 'planning', startDate: { $lte: now }, endDate: { $gte: now } },
      { $set: { status: 'active' } }
    );
    await Planning.updateMany(
      { userId: req.user._id, status: { $in: ['planning', 'active'] }, endDate: { $lt: now } },
      { $set: { status: 'completed' } }
    );
    
    const plannings = await Planning.find(query).sort({ startDate: -1 });
    res.json(plannings);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   POST /api/planning
// @desc    Create a new planning entry
router.post('/', auth, async (req, res) => {
  try {
    const { destination, countryCode, startDate, endDate, partySize, notes } = req.body;

    // Fetch country info
    let destinationInfo = {};
    try {
      const cacheKey = `country_${countryCode}`;
      let countryData = getCached(cacheKey);
      
      if (!countryData) {
        countryData = await callWithFallback(
          () => axiosGet(`https://restcountries.com/v3.1/alpha/${countryCode}`),
          () => axiosGet(`https://countriesnow.space/api/v0.1/countries/info?returns=currency,flag&country=${destination}`),
          'Country Info'
        );
        setCache(cacheKey, countryData);
      }

      if (Array.isArray(countryData) && countryData[0]) {
        const c = countryData[0];
        const currencyKey = c.currencies ? Object.keys(c.currencies)[0] : '';
        const langKey = c.languages ? Object.keys(c.languages)[0] : '';
        destinationInfo = {
          currency: currencyKey,
          language: langKey ? c.languages[langKey] : '',
          timezone: c.timezones ? c.timezones[0] : '',
          capital: c.capital ? c.capital[0] : '',
          population: c.population || 0,
          flagUrl: c.flags?.png || '',
        };
      }
    } catch (err) {
      console.warn('Could not fetch country info:', err.message);
    }

    // Auto-generate checklist
    const checklist = generateChecklist(destinationInfo, startDate, endDate);

    const planning = new Planning({
      userId: req.user._id,
      destination,
      countryCode,
      countryName: destination,
      startDate,
      endDate,
      partySize: partySize || 1,
      notes: notes || '',
      destinationInfo,
      checklist,
    });

    await planning.save();
    res.status(201).json(planning);
  } catch (error) {
    console.error('Create planning error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// @route   GET /api/planning/:id
// @desc    Get a single planning entry
router.get('/:id', auth, async (req, res) => {
  try {
    const planning = await Planning.findOne({ _id: req.params.id, userId: req.user._id });
    if (!planning) {
      return res.status(404).json({ message: 'Planning not found' });
    }
    res.json(planning);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   PUT /api/planning/:id
// @desc    Update a planning entry
router.put('/:id', auth, async (req, res) => {
  try {
    const planning = await Planning.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      { $set: req.body },
      { new: true }
    );
    if (!planning) {
      return res.status(404).json({ message: 'Planning not found' });
    }
    res.json(planning);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   PUT /api/planning/:id/checklist/:itemIndex
// @desc    Toggle checklist item
router.put('/:id/checklist/:itemIndex', auth, async (req, res) => {
  try {
    const planning = await Planning.findOne({ _id: req.params.id, userId: req.user._id });
    if (!planning) {
      return res.status(404).json({ message: 'Planning not found' });
    }

    const index = parseInt(req.params.itemIndex);
    if (index >= 0 && index < planning.checklist.length) {
      planning.checklist[index].checked = !planning.checklist[index].checked;
      await planning.save();
    }

    res.json(planning);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/planning/:id
// @desc    Delete a planning entry
router.delete('/:id', auth, async (req, res) => {
  try {
    const planning = await Planning.findOneAndDelete({ _id: req.params.id, userId: req.user._id });
    if (!planning) {
      return res.status(404).json({ message: 'Planning not found' });
    }
    res.json({ message: 'Planning deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Helper: Generate pre-departure checklist
function generateChecklist(destInfo, startDate, endDate) {
  const items = [];

  // Documents
  items.push({ item: 'Check passport validity (6+ months)', category: 'documents', checked: false, autoGenerated: true });
  items.push({ item: 'Check visa requirements', category: 'visa', checked: false, autoGenerated: true });
  items.push({ item: 'Make copies of important documents', category: 'documents', checked: false, autoGenerated: true });
  items.push({ item: 'Print/save hotel booking confirmations', category: 'documents', checked: false, autoGenerated: true });

  // Health
  items.push({ item: 'Check recommended vaccinations', category: 'health', checked: false, autoGenerated: true });
  items.push({ item: 'Pack prescription medications', category: 'health', checked: false, autoGenerated: true });
  items.push({ item: 'Get travel health insurance', category: 'health', checked: false, autoGenerated: true });

  // Finance
  if (destInfo.currency) {
    items.push({ item: `Get local currency: ${destInfo.currency}`, category: 'finance', checked: false, autoGenerated: true });
  }
  items.push({ item: 'Notify bank of travel dates', category: 'finance', checked: false, autoGenerated: true });
  items.push({ item: 'Set up travel-friendly credit card', category: 'finance', checked: false, autoGenerated: true });

  // Packing
  items.push({ item: 'Pack weather-appropriate clothing', category: 'packing', checked: false, autoGenerated: true });
  items.push({ item: 'Pack chargers and power adapter', category: 'packing', checked: false, autoGenerated: true });
  items.push({ item: 'Pack toiletries', category: 'packing', checked: false, autoGenerated: true });
  items.push({ item: 'Download offline maps', category: 'packing', checked: false, autoGenerated: true });

  // Language
  if (destInfo.language) {
    items.push({ item: `Learn basic phrases in ${destInfo.language}`, category: 'other', checked: false, autoGenerated: true });
  }

  return items;
}

module.exports = router;
