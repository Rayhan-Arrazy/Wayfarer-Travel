const express = require('express');
const auth = require('../../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/proxy/countries/:code
// @desc    Get country info by code
router.get('/countries/:code', auth, async (req, res) => {
  try {
    const cacheKey = `country_${req.params.code}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await callWithFallback(
        () => axiosGet(`https://restcountries.com/v3.1/alpha/${req.params.code}`),
        () => axiosGet(`https://countriesnow.space/api/v0.1/countries/iso`, { params: { iso: req.params.code } }),
        'Countries'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/countries/search/:name
// @desc    Search countries by name
router.get('/countries/search/:name', auth, async (req, res) => {
  try {
    const cacheKey = `country_search_${req.params.name}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await axiosGet(`https://restcountries.com/v3.1/name/${req.params.name}`);
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/countries
// @desc    Get all countries
router.get('/countries', auth, async (req, res) => {
  try {
    const cacheKey = 'all_countries';
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await axiosGet('https://restcountries.com/v3.1/all?fields=name,cca2,flags,capital,region');
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
