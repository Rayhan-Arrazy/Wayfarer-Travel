const express = require('express');
const auth = require('../../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/proxy/weather/current
// @desc    Get current weather by coordinates
router.get('/current', async (req, res) => {
  try {
    const { lat, lng } = req.query;
    if (!lat || !lng) {
      return res.status(400).json({ message: 'lat and lng are required' });
    }

    const cacheKey = `weather_current_${lat}_${lng}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await callWithFallback(
        () => axiosGet(`https://api.open-meteo.com/v1/forecast`, {
          params: {
            latitude: lat, longitude: lng,
            current: 'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,uv_index',
            hourly: 'temperature_2m,precipitation_probability,weather_code',
            daily: 'temperature_2m_max,temperature_2m_min,precipitation_sum,uv_index_max,weather_code,sunrise,sunset',
            timezone: 'auto',
            forecast_days: 16,
          }
        }),
        () => axiosGet(`https://api.weatherapi.com/v1/forecast.json`, {
          params: { key: process.env.WEATHER_API_KEY, q: `${lat},${lng}`, days: 14 }
        }),
        'Weather'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/weather/air-quality
// @desc    Get air quality data
router.get('/air-quality', async (req, res) => {
  try {
    const { lat, lng } = req.query;
    const data = await axiosGet(`https://air-quality-api.open-meteo.com/v1/air-quality`, {
      params: {
        latitude: lat, longitude: lng,
        current: 'us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,ozone',
        hourly: 'us_aqi,pm2_5',
        timezone: 'auto',
      }
    });
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/weather/astronomy
// @desc    Get sunrise/sunset data
router.get('/astronomy', async (req, res) => {
  try {
    const { lat, lng, date } = req.query;
    const cacheKey = `astronomy_${lat}_${lng}_${date}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await callWithFallback(
        () => axiosGet(`https://api.sunrisesunset.io/json`, {
          params: { lat, lng, date: date || 'today' }
        }),
        () => axiosGet(`https://api.weatherapi.com/v1/astronomy.json`, {
          params: { key: process.env.WEATHER_API_KEY, q: `${lat},${lng}`, dt: date }
        }),
        'Astronomy'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
