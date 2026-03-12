const express = require('express');
const auth = require('../../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/proxy/food/restaurants
// @desc    Search restaurants nearby
router.get('/restaurants', auth, async (req, res) => {
  try {
    const { lat, lng, query, radius, limit } = req.query;
    
    // Use Overpass API for restaurant search (free, no API key needed)
    const rad = radius || 1500;
    const overpassQuery = `
      [out:json][timeout:25];
      (
        node["amenity"="restaurant"](around:${rad},${lat},${lng});
        node["amenity"="cafe"](around:${rad},${lat},${lng});
        node["amenity"="fast_food"](around:${rad},${lat},${lng});
      );
      out body;
    `;

    const data = await axiosGet(`https://overpass-api.de/api/interpreter`, {
      params: { data: overpassQuery }
    });
    
    // Format results
    const restaurants = (data.elements || []).map(el => ({
      id: el.id,
      name: el.tags?.name || 'Unknown Restaurant',
      cuisine: el.tags?.cuisine || '',
      phone: el.tags?.phone || '',
      website: el.tags?.website || '',
      openingHours: el.tags?.opening_hours || '',
      lat: el.lat,
      lng: el.lon,
      diet: {
        halal: el.tags?.['diet:halal'] === 'yes',
        vegan: el.tags?.['diet:vegan'] === 'yes',
        vegetarian: el.tags?.['diet:vegetarian'] === 'yes',
        glutenFree: el.tags?.['diet:gluten_free'] === 'yes',
      },
      wheelchair: el.tags?.wheelchair || '',
    })).filter(r => r.name !== 'Unknown Restaurant');
    
    res.json({ restaurants, total: restaurants.length });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/food/cuisine/:country
// @desc    Get traditional cuisine for a country
router.get('/cuisine/:country', auth, async (req, res) => {
  try {
    const cacheKey = `cuisine_${req.params.country}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await callWithFallback(
        () => axiosGet(`https://www.themealdb.com/api/json/v1/1/filter.php`, {
          params: { a: req.params.country }
        }),
        () => axiosGet(`https://www.themealdb.com/api/json/v1/1/search.php`, {
          params: { s: req.params.country }
        }),
        'Cuisine'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/food/meal/:id
// @desc    Get meal details by ID
router.get('/meal/:id', auth, async (req, res) => {
  try {
    const data = await axiosGet(`https://www.themealdb.com/api/json/v1/1/lookup.php`, {
      params: { i: req.params.id }
    });
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/food/barcode/:code
// @desc    Get product info by barcode
router.get('/barcode/:code', auth, async (req, res) => {
  try {
    const data = await callWithFallback(
      () => axiosGet(`https://world.openfoodfacts.org/api/v0/product/${req.params.code}.json`),
      () => axiosGet(`https://api.upcitemdb.com/prod/trial/lookup`, {
        params: { upc: req.params.code }
      }),
      'Barcode'
    );
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
