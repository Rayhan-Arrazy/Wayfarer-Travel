const express = require('express');
const router = express.Router();
const CountryGuide = require('../../models/CountryGuide');
const { axiosGet, getUnsplashImage, setCache, getCached } = require('../../utils/apiHelpers');

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

// @route   GET api/proxy/guides/search
// @desc    Search countries dynamically (Local first, then REST Countries)
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.status(400).json({ message: 'Search query required' });

    // 1. Try Local Database
    const localGuides = await CountryGuide.find({
      $or: [
        { name: { $regex: q, $options: 'i' } },
        { countryCode: { $regex: q, $options: 'i' } }
      ]
    });

    if (localGuides.length > 0) {
      return res.json(localGuides);
    }

    // 2. Try External API (REST Countries)
    const cacheKey = `country_search_${q.toLowerCase()}`;
    let externalData = getCached(cacheKey);

    if (!externalData) {
      try {
        const results = await axiosGet(`https://restcountries.com/v3.1/name/${encodeURIComponent(q)}`);
        
        // Map to CountryGuide format
        const dynamicGuides = await Promise.all(results.map(async (c) => {
          const name = c.name.common;
          const imageUrl = await getUnsplashImage(`${name} travel landscape`);
          
          return {
            _id: `dynamic_${c.cca2}`,
            name: name,
            countryCode: c.cca2,
            flagUrl: c.flags.png,
            coverImage: imageUrl || 'https://images.unsplash.com/photo-1488646953014-85cb44e25828',
            description: `${name} is a beautiful destination in ${c.region}. Known for its rich history and vibrant culture.`,
            language: Object.values(c.languages || {})[0] || 'English',
            currency: Object.keys(c.currencies || {})[0] || 'USD',
            capital: c.capital?.[0] || 'Unknown',
            region: c.region,
            population: c.population,
            latlng: c.latlng,
            isDynamic: true
          };
        }));
        
        externalData = dynamicGuides;
        setCache(cacheKey, externalData, 60 * 60 * 1000); // Cache for 1 hour
      } catch (err) {
        return res.json([]); // No results found anywhere
      }
    }

    res.json(externalData);
  } catch (err) {
    console.error('Search error:', err);
    res.status(500).json({ message: 'Server Error' });
  }
});

module.exports = router;
