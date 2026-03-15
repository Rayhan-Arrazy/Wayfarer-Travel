const mongoose = require('mongoose');
const User = require('./models/User');
const Trip = require('./models/Trip');
const JournalEntry = require('./models/JournalEntry');
const Favorite = require('./models/Favorite');
const dotenv = require('dotenv');

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/wayfarer';

async function seed() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('--- CONNECTED TO DB ---');

    // 1. Clear existing data
    await User.deleteMany({});
    await Trip.deleteMany({});
    await JournalEntry.deleteMany({});
    await Favorite.deleteMany({});
    console.log('--- CLEARED COLLECTIONS ---');

    // 2. Create Admin and User
    const admin = await User.create({
      name: 'Admin Sarah',
      email: 'admin@wayfarer.com',
      password: 'password123',
      role: 'admin',
      homeCurrency: 'USD',
      homeCountry: 'US',
      isActive: true,
      emergencyContacts: [
        { name: 'John Doe', relationship: 'Partner', phone: '+1234567890' }
      ]
    });

    const user = await User.create({
      name: 'Marcus Thorne',
      email: 'user@wayfarer.com',
      password: 'password123',
      role: 'user',
      homeCurrency: 'USD',
      homeCountry: 'ID',
      isActive: true,
      emergencyContacts: [
        { name: 'Elena Thorne', relationship: 'Sister', phone: '+628123456789' }
      ]
    });
    console.log('--- USERS CREATED ---');

    // 3. Create Trips (Marcus)
    const activeTrip = await Trip.create({
      userId: user._id,
      destination: 'Bali, Indonesia',
      countryCode: 'ID',
      countryName: 'Indonesia',
      startDate: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), 
      endDate: new Date(Date.now() + 4 * 24 * 60 * 60 * 1000),
      partySize: 2,
      status: 'active',
      coverImage: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
      budget: { amount: 2500, currency: 'USD' },
      checklist: [
        { item: 'Apply for e-VOA', category: 'visa', checked: true },
        { item: 'Book Ubud Villa', category: 'packing', checked: true },
        { item: 'Pack Sunscreen', category: 'packing', checked: true },
        { item: 'Exchange Currency', category: 'finance', checked: false }
      ],
      destinationInfo: {
        currency: 'IDR',
        language: 'Indonesion',
        capital: 'Jakarta',
        timezone: 'WITA'
      }
    });

    const upcomingTrip = await Trip.create({
      userId: user._id,
      destination: 'Tokyo, Japan',
      countryCode: 'JP',
      countryName: 'Japan',
      startDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), 
      endDate: new Date(Date.now() + 37 * 24 * 60 * 60 * 1000),
      partySize: 1,
      status: 'planning',
      coverImage: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf',
      budget: { amount: 4000, currency: 'USD' }
    });

    const completedTrip = await Trip.create({
      userId: user._id,
      destination: 'Paris, France',
      countryCode: 'FR',
      countryName: 'France',
      startDate: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000), 
      endDate: new Date(Date.now() - 53 * 24 * 60 * 60 * 1000),
      status: 'completed',
      coverImage: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34'
    });
    console.log('--- TRIPS CREATED ---');

    // 4. Create Journal Entries
    await JournalEntry.create([
      {
        userId: user._id,
        tripId: activeTrip._id,
        title: 'Arrival in Paradise',
        note: 'The heat hit me as soon as I stepped off the plane. Ubud is magical at night.',
        location: { lat: -8.5069, lng: 115.2625, name: 'Ubud, Bali', country: 'Indonesia' },
        mood: 'amazing',
        weather: { temp: 28, description: 'Clear Sky', icon: '01d' },
        photos: [{ url: 'https://images.unsplash.com/photo-1537944434965-cf4679d1a598', caption: 'Airport' }]
      },
      {
        userId: user._id,
        tripId: activeTrip._id,
        title: 'Exploring Tegenungan',
        note: 'Breathless. The stairs back up were tough though!',
        location: { lat: -8.5751, lng: 115.2898, name: 'Tegenungan Waterfall', country: 'Indonesia' },
        mood: 'happy',
        weather: { temp: 30, description: 'Sunny', icon: '01d' },
        photos: [{ url: 'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2', caption: 'Waterfall' }]
      }
    ]);
    console.log('--- JOURNALS CREATED ---');

    // 5. Create Favorites
    await Favorite.create([
      {
        userId: user._id,
        type: 'restaurant',
        name: 'Ramen Ichiraku',
        address: 'Naruto St 4, Tokyo, JP',
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624'
      },
      {
        userId: user._id,
        type: 'hotel',
        name: 'The Ritz Paris',
        address: '15 Place Vendôme, Paris, FR',
        rating: 5.0,
        imageUrl: 'https://images.unsplash.com/photo-1541976590-713ea5488c17'
      }
    ]);
    console.log('--- FAVORITES CREATED ---');

    console.log('--- ALL DATA SEEDED SUCCESSFULLY ---');
    process.exit(0);
  } catch (err) {
    console.error('ERROR SEEDING DATA:', err);
    process.exit(1);
  }
}

seed();
