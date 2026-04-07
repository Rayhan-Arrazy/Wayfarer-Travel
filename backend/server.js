require('dotenv').config();
const express = require('express');
const path = require('path');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const connectDB = require('./config/db');

const app = express();

// Connect to MongoDB
connectDB();

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // limit each IP to 200 requests per windowMs
  message: { message: 'Too many requests, please try again later.' },
});
app.use('/api/', limiter);

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/trips', require('./routes/trips'));
app.use('/api/journal', require('./routes/journal'));
app.use('/api/budgets', require('./routes/budgets'));
app.use('/api/admin', require('./routes/admin'));

// Proxy routes (external API wrappers)
app.use('/api/proxy/countries', require('./routes/proxy/countries'));
app.use('/api/proxy/weather', require('./routes/proxy/weather'));
app.use('/api/proxy/currency', require('./routes/proxy/currency'));
app.use('/api/proxy/places', require('./routes/proxy/places'));
app.use('/api/proxy/food', require('./routes/proxy/food'));
app.use('/api/proxy/transport', require('./routes/proxy/transport'));
app.use('/api/proxy/emergency', require('./routes/proxy/emergency'));
app.use('/api/proxy/accommodation', require('./routes/proxy/accommodation'));
app.use('/api/proxy/guides', require('./routes/proxy/guides'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Wayfarer API is running', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!', error: err.message });
});

// Base API route
app.get('/api', (req, res) => {
  res.json({ message: 'Wayfarer API is active' });
});

// Serve Flutter Web Build
app.use(express.static(path.join(__dirname, '../wayfarer/build/web')));

// Root route - serve index.html for Flutter Web
app.get('*', (req, res, next) => {
  // If request contains /api/, skip to next (let API routes handle it)
  if (req.url.startsWith('/api/')) return next();
  res.sendFile(path.join(__dirname, '../wayfarer/build/web/index.html'));
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// const PORT = process.env.PORT || 5000;
// app.listen(PORT, () => {
//   console.log(`Wayfarer API Server running on port ${PORT}`);
//   console.log(`Health check: http://localhost:${PORT}/api/health`);
// });

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
