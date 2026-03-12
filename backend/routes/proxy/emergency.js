const express = require('express');
const auth = require('../../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/proxy/emergency/numbers/:countryCode
// @desc    Get emergency numbers for a country
router.get('/numbers/:countryCode', auth, async (req, res) => {
  try {
    const cacheKey = `emergency_${req.params.countryCode}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await callWithFallback(
        () => axiosGet(`https://emergencynumberapi.com/api/country/${req.params.countryCode}`),
        async () => {
          const countryData = await axiosGet(`https://restcountries.com/v3.1/alpha/${req.params.countryCode}`);
          return {
            country: countryData[0]?.name?.common,
            callingCode: countryData[0]?.idd?.root + (countryData[0]?.idd?.suffixes?.[0] || ''),
            police: { all: ['112'] },
            ambulance: { all: ['112'] },
            fire: { all: ['112'] },
          };
        },
        'Emergency Numbers'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/emergency/hospitals
// @desc    Get nearby hospitals and pharmacies
router.get('/hospitals', auth, async (req, res) => {
  try {
    const { lat, lng, radius } = req.query;
    const rad = radius || 5000;
    
    const overpassQuery = `
      [out:json][timeout:25];
      (
        node["amenity"="hospital"](around:${rad},${lat},${lng});
        node["amenity"="clinic"](around:${rad},${lat},${lng});
        node["amenity"="pharmacy"](around:${rad},${lat},${lng});
        way["amenity"="hospital"](around:${rad},${lat},${lng});
      );
      out center body;
    `;

    const data = await axiosGet(`https://overpass-api.de/api/interpreter`, {
      params: { data: overpassQuery }
    });
    
    const facilities = (data.elements || []).map(el => ({
      id: el.id,
      name: el.tags?.name || (el.tags?.amenity === 'pharmacy' ? 'Pharmacy' : 'Medical Facility'),
      type: el.tags?.amenity || 'hospital',
      phone: el.tags?.phone || el.tags?.['contact:phone'] || '',
      address: [el.tags?.['addr:street'], el.tags?.['addr:housenumber'], el.tags?.['addr:city']].filter(Boolean).join(', '),
      emergency: el.tags?.emergency === 'yes',
      openingHours: el.tags?.opening_hours || '',
      lat: el.lat || el.center?.lat,
      lng: el.lon || el.center?.lon,
    }));
    
    res.json({ facilities, total: facilities.length });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/emergency/health-alerts
// @desc    Get WHO health alerts
router.get('/health-alerts', auth, async (req, res) => {
  try {
    const cacheKey = 'who_health_alerts';
    let data = getCached(cacheKey);
    
    if (!data) {
      try {
        data = await axiosGet('https://www.who.int/rss-feeds/news-english.xml');
      } catch (err) {
        data = { message: 'Health alerts currently unavailable', alerts: [] };
      }
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/proxy/emergency/sos
// @desc    Send SOS SMS to emergency contacts
router.post('/sos', auth, async (req, res) => {
  try {
    const { contacts, location, message } = req.body;
    
    if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
      return res.json({ 
        message: 'SOS feature requires Twilio credentials. Configure in .env',
        sent: false 
      });
    }

    const axios = require('axios');
    const results = [];
    
    for (const contact of contacts) {
      try {
        await axios.post(
          `https://api.twilio.com/2010-04-01/Accounts/${process.env.TWILIO_ACCOUNT_SID}/Messages.json`,
          new URLSearchParams({
            To: contact.phone,
            From: process.env.TWILIO_PHONE_NUMBER,
            Body: message || `🆘 EMERGENCY: I need help! My current location: ${location.lat}, ${location.lng}. ${location.name || ''}`,
          }),
          {
            auth: {
              username: process.env.TWILIO_ACCOUNT_SID,
              password: process.env.TWILIO_AUTH_TOKEN,
            }
          }
        );
        results.push({ phone: contact.phone, sent: true });
      } catch (err) {
        results.push({ phone: contact.phone, sent: false, error: err.message });
      }
    }
    
    res.json({ results, sent: true });
  } catch (error) {
    res.status(500).json({ message: error.message, sent: false });
  }
});

module.exports = router;
