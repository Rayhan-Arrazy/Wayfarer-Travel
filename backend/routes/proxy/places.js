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
    const { lat, lng, type, radius } = req.query;
    const rad = parseInt(radius) || 2000;
    const requestedTypes = (type || 'all').split(',');
    
    const categoryFilters = {
      emergency: `
        nwr["amenity"~"hospital|pharmacy|clinic|doctors|dentist|veterinary|social_facility"](around:${rad},${lat},${lng});
      `,
      financial: `
        nwr["amenity"~"atm|bank|bureau_de_change|money_transfer|payment_terminal"](around:${rad},${lat},${lng});
      `,
      restaurant: `
        nwr["amenity"~"restaurant|cafe|fast_food|bar|pub|ice_cream|food_court|biergarten"](around:${rad},${lat},${lng});
      `,
      station: `
        nwr["railway"~"station|halt|tram_stop"](around:${rad},${lat},${lng});
        nwr["amenity"~"bus_station|taxi|ferry_terminal|bus_stop"](around:${rad},${lat},${lng});
        nwr["public_transport"~"station|stop_area"](around:${rad},${lat},${lng});
      `,
      tourism: `
        nwr["tourism"~"attraction|museum|viewpoint|artwork|zoo|theme_park|gallery|information"](around:${rad},${lat},${lng});
        nwr["historic"~"monument|memorial|statue|castle|ruins"](around:${rad},${lat},${lng});
      `,
      hotel: `
        nwr["tourism"~"hotel|hostel|guest_house|motel|camp_site|apartment"](around:${rad},${lat},${lng});
      `,
      shopping: `
        nwr["shop"~"mall|supermarket|convenience|clothes|electronics|department_store|bakery|beauty|gift|jewelry|outdoor|sports"](around:${rad},${lat},${lng});
        nwr["amenity"="marketplace"](around:${rad},${lat},${lng});
      `,
      services: `
        nwr["amenity"~"post_office|laundry|police|library|townhall|embassy|post_box|car_rental|car_wash|parking"](around:${rad},${lat},${lng});
      `
    };

    let overpassFilter = '';
    
    if (requestedTypes.includes('all')) {
      overpassFilter = Object.values(categoryFilters).join('\n');
    } else {
      requestedTypes.forEach(t => {
        if (categoryFilters[t]) {
          overpassFilter += categoryFilters[t];
        } else {
          overpassFilter += `
            nwr["amenity"="${t}"](around:${rad},${lat},${lng});
            nwr["tourism"="${t}"](around:${rad},${lat},${lng});
            nwr["shop"="${t}"](around:${rad},${lat},${lng});
            nwr["historic"="${t}"](around:${rad},${lat},${lng});
          `;
        }
      });
    }

    const overpassQuery = `
      [out:json][timeout:30];
      (
        ${overpassFilter}
      );
      out center body 150;
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
