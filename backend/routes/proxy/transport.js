const express = require('express');
const auth = require('../../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/proxy/transport/routes
// @desc    Get transport options between two locations
router.get('/routes', async (req, res) => {
  try {
    const { fromLat, fromLng, toLat, toLng, from, to } = req.query;
    
    // Use OSRM for driving route as primary free option
    const data = await callWithFallback(
      () => axiosGet(`https://router.project-osrm.org/route/v1/driving/${fromLng},${fromLat};${toLng},${toLat}`, {
        params: { overview: 'full', geometries: 'geojson', steps: true, alternatives: true }
      }),
      () => axiosGet(`https://api.openrouteservice.org/v2/directions/driving-car`, {
        params: { start: `${fromLng},${fromLat}`, end: `${toLng},${toLat}` },
        headers: { 'Authorization': process.env.OPENROUTESERVICE_API_KEY }
      }),
      'Transport Routes'
    );
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/transport/transit
// @desc    Get public transit info nearby
router.get('/transit', async (req, res) => {
  try {
    const { lat, lng, radius } = req.query;
    const rad = radius || 500;
    
    // Use Overpass API to find transit stops
    const overpassQuery = `
      [out:json][timeout:25];
      (
        node["public_transport"="stop_position"](around:${rad},${lat},${lng});
        node["highway"="bus_stop"](around:${rad},${lat},${lng});
        node["railway"="station"](around:${rad},${lat},${lng});
        node["railway"="tram_stop"](around:${rad},${lat},${lng});
      );
      out body;
    `;

    const data = await axiosGet(`https://overpass-api.de/api/interpreter`, {
      params: { data: overpassQuery }
    });
    
    const stops = (data.elements || []).map(el => ({
      id: el.id,
      name: el.tags?.name || 'Unknown Stop',
      type: el.tags?.railway || el.tags?.highway || el.tags?.public_transport || 'stop',
      operator: el.tags?.operator || '',
      network: el.tags?.network || '',
      lat: el.lat,
      lng: el.lon,
      routes: el.tags?.route_ref || '',
    }));
    
    res.json({ stops, total: stops.length });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/transport/flights
// @desc    Search flights (Amadeus sandbox)
router.get('/flights', async (req, res) => {
  try {
    const { origin, destination, departureDate, adults } = req.query;
    
    // Try Amadeus sandbox first
    if (process.env.AMADEUS_API_KEY && process.env.AMADEUS_API_SECRET) {
      try {
        // Get access token
        const tokenRes = await axiosGet('https://test.api.amadeus.com/v1/security/oauth2/token', {
          method: 'POST',
          data: `grant_type=client_credentials&client_id=${process.env.AMADEUS_API_KEY}&client_secret=${process.env.AMADEUS_API_SECRET}`,
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });
        
        const flightData = await axiosGet('https://test.api.amadeus.com/v2/shopping/flight-offers', {
          params: { originLocationCode: origin, destinationLocationCode: destination, departureDate, adults: adults || 1, max: 10 },
          headers: { 'Authorization': `Bearer ${tokenRes.access_token}` }
        });
        
        return res.json(flightData);
      } catch (err) {
        console.warn('Amadeus failed:', err.message);
      }
    }
    
    // Fallback response
    res.json({ 
      message: 'Flight search requires Amadeus API credentials. Add AMADEUS_API_KEY and AMADEUS_API_SECRET to .env',
      data: []
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
