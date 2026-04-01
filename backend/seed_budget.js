const mongoose = require('mongoose');

async function seed() {
  try {
    await mongoose.connect('mongodb://localhost:27017/wayfarer');
    console.log('Connected to MongoDB');

    // Mongoose pluralizes 'Budget' to 'budgets'
    const Budget = mongoose.connection.db.collection('budgets');
    
    // Create a dummy record to force collection creation
    const result = await Budget.insertOne({
      title: 'Initial Seed Budget',
      amount: 0,
      currency: 'USD',
      expenses: [],
      createdAt: new Date(),
      updatedAt: new Date()
    });

    console.log('Collection "budgets" created with dummy record.');
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

seed();
