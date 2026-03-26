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
const DEFAULT_TTL = 10 * 60 * 1000; // 10 minutes

const getCached = (key) => {
  const item = cache.get(key);
  if (item && Date.now() - item.timestamp < (item.ttl || DEFAULT_TTL)) {
    return item.data;
  }
  cache.delete(key);
  return null;
};

const setCache = (key, data, ttl = DEFAULT_TTL) => {
  cache.set(key, { data, timestamp: Date.now(), ttl });
  if (cache.size > 1000) {
    const oldest = [...cache.entries()]
      .sort((a, b) => a[1].timestamp - b[1].timestamp)
      .slice(0, 200);
    oldest.forEach(([k]) => cache.delete(k));
  }
};

const axiosGet = async (url, options = {}) => {
  const response = await axios.get(url, { timeout: 15000, ...options });
  return response.data;
};

// Fetch high-res travel images
const getUnsplashImage = async (query) => {
  const cacheKey = `unsplash_${query.toLowerCase()}`;
  let data = getCached(cacheKey);
  if (data) return data;

  try {
    // Attempt with key if exists, otherwise use source.unsplash (deprecated but works for some) 
    // or just return a high-quality deterministic placeholder
    const accessKey = process.env.UNSPLASH_ACCESS_KEY;
    if (accessKey) {
      const res = await axios.get(`https://api.unsplash.com/search/photos`, {
        params: { query, per_page: 1, orientation: 'landscape' },
        headers: { Authorization: `Client-ID ${accessKey}` }
      });
      const url = res.data.results[0]?.urls?.regular;
      if (url) {
        setCache(cacheKey, url, 24 * 60 * 60 * 1000); // Cache image for 24h
        return url;
      }
    }
    
    // Fallback: Use dynamic source image from a more reliable provider if no key
    const travelPhotos = [
      'https://images.unsplash.com/photo-1488646953014-85cb44e25828', // Luggage
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1', // Mountains
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e', // Beach
      'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800', // Road trip
      'https://images.unsplash.com/photo-1530789253388-582c481c54b0', // Traveler
    ];
    const randomIndex = Math.abs(query.split('').reduce((a, b) => a + b.charCodeAt(0), 0)) % travelPhotos.length;
    const fallback = `${travelPhotos[randomIndex]}?q=80&w=800&auto=format&fit=crop`;
    return fallback;
  } catch (err) {
    return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?q=80&w=800&auto=format&fit=crop';
  }
};

module.exports = { callWithFallback, getCached, setCache, axiosGet, getUnsplashImage };
