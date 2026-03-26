const express = require('express');
const auth = require('../../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/proxy/accommodation/search
// @desc    Search for accommodation (hotels, hostels, apartments) using Overpass/OSM
router.get('/search', async (req, res) => {
  try {
    const { lat, lng, radius, type } = req.query;
    const rad = radius || 5000;
    
    // Build Overpass query based on type filter
    let amenityFilter = '';
    switch (type) {
      case 'hotel':
        amenityFilter = 'node["tourism"="hotel"]';
        break;
      case 'hostel':
        amenityFilter = 'node["tourism"="hostel"]';
        break;
      case 'apartment':
        amenityFilter = 'node["tourism"="apartment"]';
        break;
      case 'resort':
        amenityFilter = 'node["tourism"="resort"]';
        break;
      default:
        amenityFilter = `
          node["tourism"="hotel"]
          node["tourism"="hostel"]
          node["tourism"="apartment"]
          node["tourism"="motel"]
          node["tourism"="guest_house"]
        `;
    }

    const cacheKey = `accommodation_${lat}_${lng}_${rad}_${type || 'all'}`;
    let data = getCached(cacheKey);

    if (!data) {
      const overpassQuery = `
        [out:json][timeout:25];
        (
          ${amenityFilter.split('\n').map(f => `${f.trim()}(around:${rad},${lat},${lng});`).join('\n')}
        );
        out body;
      `;

      const rawData = await axiosGet('https://overpass-api.de/api/interpreter', {
        params: { data: overpassQuery }
      });

      const accommodations = (rawData.elements || []).map(el => {
        const tags = el.tags || {};
        return {
          id: el.id,
          name: tags.name || tags['name:en'] || 'Accommodation',
          type: tags.tourism || 'hotel',
          stars: parseInt(tags.stars) || null,
          phone: tags.phone || tags['contact:phone'] || '',
          website: tags.website || tags['contact:website'] || '',
          email: tags.email || tags['contact:email'] || '',
          address: [tags['addr:street'], tags['addr:housenumber'], tags['addr:city']]
            .filter(Boolean).join(', '),
          amenities: _extractAmenities(tags),
          wheelchair: tags.wheelchair || '',
          internetAccess: tags.internet_access || '',
          lat: el.lat,
          lng: el.lon,
        };
      });

      data = { accommodations, total: accommodations.length };
      setCache(cacheKey, data, 600); // Cache for 10 min
    }

    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/accommodation/details/:id
// @desc    Get accommodation details by OSM node ID
router.get('/details/:id', async (req, res) => {
  try {
    const cacheKey = `accommodation_detail_${req.params.id}`;
    let data = getCached(cacheKey);

    if (!data) {
      const overpassQuery = `
        [out:json];
        node(${req.params.id});
        out body;
      `;

      const rawData = await axiosGet('https://overpass-api.de/api/interpreter', {
        params: { data: overpassQuery }
      });

      if (rawData.elements && rawData.elements.length > 0) {
        const el = rawData.elements[0];
        const tags = el.tags || {};
        data = {
          id: el.id,
          name: tags.name || 'Accommodation',
          type: tags.tourism || 'hotel',
          stars: parseInt(tags.stars) || null,
          phone: tags.phone || tags['contact:phone'] || '',
          website: tags.website || tags['contact:website'] || '',
          email: tags.email || tags['contact:email'] || '',
          address: [tags['addr:street'], tags['addr:housenumber'], tags['addr:postcode'], tags['addr:city']]
            .filter(Boolean).join(', '),
          openingHours: tags.opening_hours || '',
          amenities: _extractAmenities(tags),
          wheelchair: tags.wheelchair || '',
          internetAccess: tags.internet_access || '',
          smokingPolicy: tags.smoking || '',
          lat: el.lat,
          lng: el.lon,
        };
        setCache(cacheKey, data, 3600);
      } else {
        data = { message: 'Accommodation not found' };
      }
    }

    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Helper: extract amenities from OSM tags
function _extractAmenities(tags) {
  const amenities = [];
  if (tags.internet_access === 'wlan' || tags.internet_access === 'yes') amenities.push('WiFi');
  if (tags['swimming_pool'] === 'yes') amenities.push('Pool');
  if (tags.parking === 'yes' || tags['parking:condition'] === 'free') amenities.push('Parking');
  if (tags.restaurant === 'yes') amenities.push('Restaurant');
  if (tags.bar === 'yes') amenities.push('Bar');
  if (tags.spa === 'yes') amenities.push('Spa');
  if (tags.fitness_centre === 'yes' || tags.gym === 'yes') amenities.push('Gym');
  if (tags.air_conditioning === 'yes') amenities.push('AC');
  if (tags.wheelchair === 'yes') amenities.push('Accessible');
  if (tags.breakfast === 'yes') amenities.push('Breakfast');
  return amenities;
}

module.exports = router;
