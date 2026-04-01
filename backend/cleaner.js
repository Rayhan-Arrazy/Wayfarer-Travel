const mongoose = require('mongoose');

async function clean() {
  try {
    await mongoose.connect('mongodb://localhost:27017/wayfarer');
    const result = await mongoose.connection.db.collection('trips').updateMany(
      {},
      { $unset: { budget: "", expenses: "" } }
    );
    console.log(`Cleaned ${result.modifiedCount} trips.`);
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

clean();
