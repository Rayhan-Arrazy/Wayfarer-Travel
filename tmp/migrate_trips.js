const mongoose = require('mongoose');

// Assuming MongoDB is running locally on default port if not specified
const mongoURI = 'mongodb://localhost:27017/wayfarer';

async function migrate() {
  try {
    await mongoose.connect(mongoURI);
    console.log('Connected to MongoDB at ' + mongoURI);

    const db = mongoose.connection.db;
    const result = await db.collection('trips').updateMany(
      {},
      { $unset: { budget: "", expenses: "" } }
    );

    console.log(`Migration complete. Removed budget/expenses from ${result.modifiedCount} trip documents.`);
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  }
}

migrate();
