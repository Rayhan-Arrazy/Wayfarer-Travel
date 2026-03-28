const express = require('express');
const User = require('../models/User');
const Trip = require('../models/Trip');
const JournalEntry = require('../models/JournalEntry');
const CountryGuide = require('../models/CountryGuide');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');
const router = express.Router();

// All admin routes require auth + admin middleware
router.use(auth, admin);

// @route   GET /api/admin/dashboard
// @desc    Get admin dashboard stats
router.get('/dashboard', async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ isActive: true });
    const totalTrips = await Trip.countDocuments();
    const activeTrips = await Trip.countDocuments({ status: 'active' });
    const completedTrips = await Trip.countDocuments({ status: 'completed' });
    const totalJournalEntries = await JournalEntry.countDocuments();

    // Recent users (last 7 days)
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const newUsersThisWeek = await User.countDocuments({ createdAt: { $gte: weekAgo } });

    // Top destinations
    const topDestinations = await Trip.aggregate([
      { $group: { _id: '$countryCode', count: { $sum: 1 }, destination: { $first: '$destination' } } },
      { $sort: { count: -1 } },
      { $limit: 10 },
    ]);

    // Monthly user registrations (last 6 months)
    const sixMonthsAgo = new Date(Date.now() - 180 * 24 * 60 * 60 * 1000);
    const monthlyRegistrations = await User.aggregate([
      { $match: { createdAt: { $gte: sixMonthsAgo } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m', date: '$createdAt' } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    res.json({
      totalUsers,
      activeUsers,
      inactiveUsers: totalUsers - activeUsers,
      totalTrips,
      activeTrips,
      completedTrips,
      totalJournalEntries,
      newUsersThisWeek,
      topDestinations,
      monthlyRegistrations,
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/admin/users
// @desc    Get all users (paginated)
router.get('/users', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search || '';
    const role = req.query.role || '';

    const query = {};
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }
    if (role) query.role = role;

    const total = await User.countDocuments(query);
    const users = await User.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit);

    res.json({
      users,
      total,
      page,
      pages: Math.ceil(total / limit),
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   PUT /api/admin/users/:id
// @desc    Update user (admin can change role, active status)
router.put('/users/:id', async (req, res) => {
  try {
    const { role, isActive } = req.body;
    const updateData = {};
    if (role !== undefined) updateData.role = role;
    if (isActive !== undefined) updateData.isActive = isActive;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { $set: updateData },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/admin/users/:id
// @desc    Delete user
router.delete('/users/:id', async (req, res) => {
  try {
    if (req.params.id === req.user._id.toString()) {
      return res.status(400).json({ message: 'Cannot delete your own account' });
    }
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    await Trip.deleteMany({ userId: req.params.id });
    await JournalEntry.deleteMany({ userId: req.params.id });
    res.json({ message: 'User and associated data deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/admin/trips
router.get('/trips', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const total = await Trip.countDocuments();
    const trips = await Trip.find()
      .populate('userId', 'name email')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit);
    res.json({ trips, total, page, pages: Math.ceil(total / limit) });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/admin/trips/:id
router.delete('/trips/:id', async (req, res) => {
  try {
    const trip = await Trip.findByIdAndDelete(req.params.id);
    if (!trip) return res.status(404).json({ message: 'Trip not found' });
    await JournalEntry.deleteMany({ tripId: req.params.id });
    res.json({ message: 'Trip deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/admin/journals
router.get('/journals', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const total = await JournalEntry.countDocuments();
    const journals = await JournalEntry.find()
      .populate('userId', 'name email')
      .populate('tripId', 'destination')
      .sort({ date: -1 })
      .skip((page - 1) * limit)
      .limit(limit);
    res.json({ journals, total, page, pages: Math.ceil(total / limit) });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/admin/journals/:id
router.delete('/journals/:id', async (req, res) => {
  try {
    const journal = await JournalEntry.findByIdAndDelete(req.params.id);
    if (!journal) return res.status(404).json({ message: 'Journal not found' });
    res.json({ message: 'Journal deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   GET /api/admin/guides
router.get('/guides', async (req, res) => {
  try {
    const guides = await CountryGuide.find().sort({ name: 1 });
    res.json({ guides, total: guides.length });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/admin/guides/:id
router.delete('/guides/:id', async (req, res) => {
  try {
    const guide = await CountryGuide.findByIdAndDelete(req.params.id);
    if (!guide) return res.status(404).json({ message: 'Guide not found' });
    res.json({ message: 'Country guide deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
