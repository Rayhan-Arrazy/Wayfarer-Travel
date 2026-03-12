const express = require('express');
const auth = require('../../middleware/auth');
const { axiosGet, callWithFallback, getCached, setCache } = require('../../utils/apiHelpers');
const router = express.Router();

// @route   GET /api/proxy/currency/rates
// @desc    Get exchange rates
router.get('/rates', auth, async (req, res) => {
  try {
    const { from, to } = req.query;
    const cacheKey = `rates_${from}_${to || 'all'}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      const params = { from: from || 'USD' };
      if (to) params.to = to;
      
      data = await callWithFallback(
        () => axiosGet(`https://api.frankfurter.dev/latest`, { params }),
        () => axiosGet(`https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/${(from || 'usd').toLowerCase()}.json`),
        'Currency'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/currency/convert
// @desc    Convert amount between currencies
router.get('/convert', auth, async (req, res) => {
  try {
    const { from, to, amount } = req.query;
    if (!from || !to || !amount) {
      return res.status(400).json({ message: 'from, to, and amount are required' });
    }

    const cacheKey = `rates_${from}_${to}`;
    let rateData = getCached(cacheKey);
    
    if (!rateData) {
      rateData = await callWithFallback(
        () => axiosGet(`https://api.frankfurter.dev/latest`, { params: { from, to } }),
        () => axiosGet(`https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/${from.toLowerCase()}.json`),
        'Currency Convert'
      );
      setCache(cacheKey, rateData);
    }

    let rate = 1;
    if (rateData.rates && rateData.rates[to]) {
      rate = rateData.rates[to];
    } else if (rateData[from.toLowerCase()] && rateData[from.toLowerCase()][to.toLowerCase()]) {
      rate = rateData[from.toLowerCase()][to.toLowerCase()];
    }

    const result = parseFloat(amount) * rate;

    res.json({
      from,
      to,
      amount: parseFloat(amount),
      rate,
      result: Math.round(result * 100) / 100,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/proxy/currency/cost-of-living
// @desc    Get cost of living data for a city
router.get('/cost-of-living', auth, async (req, res) => {
  try {
    const { city } = req.query;
    const cacheKey = `col_${city}`;
    let data = getCached(cacheKey);
    
    if (!data) {
      data = await callWithFallback(
        () => axiosGet(`https://api.teleport.org/api/urban_areas/slug:${city.toLowerCase().replace(/\s+/g, '-')}/scores/`),
        () => ({ message: 'Cost of living data not available for this city' }),
        'Cost of Living'
      );
      setCache(cacheKey, data);
    }
    
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
