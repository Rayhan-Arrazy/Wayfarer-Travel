const mongoose = require('mongoose');
const User = require('./models/User');
const dotenv = require('dotenv');

dotenv.config();

mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/wayfarer').then(async () => {
  console.log('Connected to DB');
  
  await User.deleteMany({ email: { $in: ['admin@wayfarer.com', 'user@wayfarer.com'] } });
  
  const admin = new User({
    name: 'Admin User',
    email: 'admin@wayfarer.com',
    password: 'password123',
    role: 'admin',
    homeCurrency: 'USD'
  });
  
  const user = new User({
    name: 'Normal User',
    email: 'user@wayfarer.com',
    password: 'password123',
    role: 'user',
    homeCurrency: 'USD'
  });
  
  await admin.save();
  await user.save();
  
  console.log('Dummy accounts created successfully');
  process.exit(0);
}).catch((err) => {
  console.error(err);
  process.exit(1);
});
