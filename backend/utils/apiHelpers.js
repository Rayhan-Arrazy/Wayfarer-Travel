const axios = require('axios');

// Generic API call with fallback
const callWithFallback = async (primaryFn, backupFn, label = 'API') => {
  try {
    return await primaryFn();
  } catch (primaryError) {
    console.warn(`${label} primary failed:`, primaryError.message);
    try {
      return await backupFn();
    } catch (backupError) {
      console.error(`${label} backup also failed:`, backupError.message);
      throw new Error(`${label}: Both primary and backup APIs failed`);
    }
  }
};

// Cached responses (simple in-memory cache)
const cache = new Map();
const CACHE_TTL = 10 * 60 * 1000; // 10 minutes

const getCached = (key) => {
  const item = cache.get(key);
  if (item && Date.now() - item.timestamp < CACHE_TTL) {
    return item.data;
  }
  cache.delete(key);
  return null;
};

const setCache = (key, data) => {
  cache.set(key, { data, timestamp: Date.now() });
  // Clean old entries if cache gets too large
  if (cache.size > 500) {
    const oldest = [...cache.entries()]
      .sort((a, b) => a[1].timestamp - b[1].timestamp)
      .slice(0, 100);
    oldest.forEach(([k]) => cache.delete(k));
  }
};

const axiosGet = async (url, options = {}) => {
  const response = await axios.get(url, { timeout: 15000, ...options });
  return response.data;
};

module.exports = { callWithFallback, getCached, setCache, axiosGet };
