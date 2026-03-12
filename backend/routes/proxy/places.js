const express = require('express');
const auth = require('../../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/proxy/places/search
// @desc    Search places by query
router.get('/search', auth, async (req, res) => {
  try {
    const { q, lat, lng } = req.query;
    const cacheKey = `places_search_${q}_${lat}_${lng}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await callWithFallback(
        () => axiosGet(`https://nominatim.openstreetmap.org/search`, {
          params: { q, format: 'json', addressdetails: 1, limit: 20 },
          headers: { 'User-Agent': 'Wayfarer-Travel-App/1.0' }
        }),
        () => axiosGet(`https://photon.komoot.io/api/`, {
          params: { q, limit: 20, lat, lon: lng }
        }),
        'Places Search'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/places/reverse
// @desc    Reverse geocode (lat/lng to address)
router.get('/reverse', auth, async (req, res) => {
  try {
    const { lat, lng } = req.query;
    const cacheKey = `reverse_${lat}_${lng}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await callWithFallback(
        () => axiosGet(`https://nominatim.openstreetmap.org/reverse`, {
          params: { lat, lon: lng, format: 'json', addressdetails: 1 },
          headers: { 'User-Agent': 'Wayfarer-Travel-App/1.0' }
        }),
        () => axiosGet(`https://photon.komoot.io/reverse`, {
          params: { lat, lon: lng }
        }),
        'Reverse Geocode'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/places/nearby
// @desc    Get nearby POIs using Overpass API
router.get('/nearby', auth, async (req, res) => {
  try {
    const { lat, lng, type, radius } = req.query;
    const rad = radius || 1000;
    
    let amenityType = type || 'restaurant';
    const overpassQuery = `
      [out:json][timeout:25];
      (
        node["amenity"="${amenityType}"](around:${rad},${lat},${lng});
        way["amenity"="${amenityType}"](around:${rad},${lat},${lng});
      );
      out center body;
    `;

    const data = await axiosGet(`https://overpass-api.de/api/interpreter`, {
      params: { data: overpassQuery }
    });
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/places/route
// @desc    Get routing directions
router.get('/route', auth, async (req, res) => {
  try {
    const { startLat, startLng, endLat, endLng, profile } = req.query;
    const routeProfile = profile || 'driving-car';
    
    const data = await callWithFallback(
      () => axiosGet(`https://api.openrouteservice.org/v2/directions/${routeProfile}`, {
        params: { start: `${startLng},${startLat}`, end: `${endLng},${endLat}` },
        headers: { 'Authorization': process.env.OPENROUTESERVICE_API_KEY }
      }),
      () => axiosGet(`https://router.project-osrm.org/route/v1/${routeProfile === 'driving-car' ? 'driving' : 'foot'}/${startLng},${startLat};${endLng},${endLat}`, {
        params: { overview: 'full', geometries: 'geojson', steps: true }
      }),
      'Routing'
    );
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/places/wikipedia
// @desc    Get Wikipedia summary for a place
router.get('/wikipedia/:place', auth, async (req, res) => {
  try {
    const cacheKey = `wiki_${req.params.place}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await callWithFallback(
        () => axiosGet(`https://en.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(req.params.place)}`),
        () => axiosGet(`https://api.duckduckgo.com/`, {
          params: { q: req.params.place, format: 'json', no_html: 1 }
        }),
        'Wikipedia'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
