const express = require('express');
const auth = require('../../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/proxy/places/search
// @desc    Search places by query
router.get('/search', async (req, res) => {
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
router.get('/reverse', async (req, res) => {
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
router.get('/nearby', async (req, res) => {
  try {
    const lat = parseFloat(req.query.lat);
    const lng = parseFloat(req.query.lng);
    const rad = parseInt(req.query.radius) || 100;
    const type = req.query.type || 'all';
    
    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ message: 'Invalid coordinates provided' });
    }

    let overpassFilter = '';
    
    if (type === 'all' || type.includes('all')) {
      // Find EVERYTHING with major traveler tags in the small radius
      overpassFilter = `
        nwr["amenity"](around:${rad},${lat},${lng});
        nwr["tourism"](around:${rad},${lat},${lng});
        nwr["shop"](around:${rad},${lat},${lng});
        nwr["historic"](around:${rad},${lat},${lng});
        nwr["leisure"](around:${rad},${lat},${lng});
        nwr["railway"~"station|halt"](around:${rad},${lat},${lng});
      `;
    } else {
      const requestedTypes = type.split(',');
      requestedTypes.forEach(t => {
        overpassFilter += `
          nwr["amenity"="${t}"](around:${rad},${lat},${lng});
          nwr["tourism"="${t}"](around:${rad},${lat},${lng});
          nwr["shop"="${t}"](around:${rad},${lat},${lng});
          nwr["historic"="${t}"](around:${rad},${lat},${lng});
          nwr["leisure"="${t}"](around:${rad},${lat},${lng});
        `;
      });
    }

    const overpassQuery = `
      [out:json][timeout:25];
      (
        ${overpassFilter}
      );
      out center body 300;
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
router.get('/route', async (req, res) => {
  try {
    const { startLat, startLng, endLat, endLng, profile } = req.query;
    const routeProfile = profile || 'driving-car';
    
    try {
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
      
      // Normalize response
      let geojson;
      if (data.features && data.features.length > 0) {
        // ORS format
        geojson = data.features[0].geometry;
      } else if (data.routes && data.routes.length > 0) {
        // OSRM format
        geojson = data.routes[0].geometry;
      }
      
      if (geojson) {
        res.json({ geometry: geojson });
      } else {
        res.status(404).json({ message: 'No route found' });
      }
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/places/wikipedia
// @desc    Get Wikipedia summary for a place
router.get('/wikipedia/:place', async (req, res) => {
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
