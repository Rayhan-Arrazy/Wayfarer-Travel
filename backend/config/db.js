const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI);
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`ERROR: Could not connect to MongoDB. Is the MongoDB service running locally?`);
    console.error(`Original Error: ${error.message}`);
    console.warn(`Server will continue to run for Proxy/External API features, but local DB features (Auth, Trips) will fail.`);
    // process.exit(1); -> Removed to prevent crash
  }
};

module.exports = connectDB;
