const express = require('express');
const Budget = require('../models/Budget');
const auth = require('../middleware/auth');
const router = express.Router();

// @route   GET /api/budgets
// @desc    Get all budgets for current user
router.get('/', auth, async (req, res) => {
  try {
    const budgets = await Budget.find({ userId: req.user._id }).sort({ createdAt: -1 });
    res.json(budgets);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   POST /api/budgets
// @desc    Create a new budget
router.post('/', auth, async (req, res) => {
  try {
    const { tripId, title, amount, currency, expenses } = req.body;

    const budget = new Budget({
      userId: req.user._id,
      tripId,
      title,
      amount,
      currency,
      expenses: expenses || [],
    });

    await budget.save();
    res.status(201).json(budget);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// @route   GET /api/budgets/:id
// @desc    Get a single budget
router.get('/:id', auth, async (req, res) => {
  try {
    const budget = await Budget.findOne({ _id: req.params.id, userId: req.user._id });
    if (!budget) {
      return res.status(404).json({ message: 'Budget not found' });
    }
    res.json(budget);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   PUT /api/budgets/:id
// @desc    Update a budget
router.put('/:id', auth, async (req, res) => {
  try {
    const budget = await Budget.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      { $set: req.body },
      { new: true }
    );
    if (!budget) {
      return res.status(404).json({ message: 'Budget not found' });
    }
    res.json(budget);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// @route   DELETE /api/budgets/:id
// @desc    Delete a budget
router.delete('/:id', auth, async (req, res) => {
  try {
    const budget = await Budget.findOneAndDelete({ _id: req.params.id, userId: req.user._id });
    if (!budget) {
      return res.status(404).json({ message: 'Budget not found' });
    }
    res.json({ message: 'Budget deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
