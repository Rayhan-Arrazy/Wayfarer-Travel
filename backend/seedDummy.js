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
    console.log('--- CONNECTED TO DB FOR MASSIVE SEEDING ---');

    await User.deleteMany({});
    await Trip.deleteMany({});
    await JournalEntry.deleteMany({});
    await Favorite.deleteMany({});
    console.log('--- CLEARED ALL COLLECTIONS ---');

    // 1. Create Users
    const users = await User.create([
      {
        name: 'Sarah Jenkins',
        email: 'admin@wayfarer.com',
        password: 'password123',
        role: 'admin',
        homeCurrency: 'USD',
        homeCountry: 'US',
        isActive: true,
        emergencyContacts: [{ name: 'Robert Jenkins', relationship: 'Father', phone: '+1555010203' }]
      },
      {
        name: 'Marcus Thorne',
        email: 'user@wayfarer.com',
        password: 'password123',
        role: 'user',
        homeCurrency: 'USD',
        homeCountry: 'ID',
        isActive: true,
        emergencyContacts: [{ name: 'Elena Thorne', relationship: 'Sister', phone: '+628123456789' }]
      },
      {
        name: 'Yuki Sato',
        email: 'yuki@example.com',
        password: 'password123',
        role: 'user',
        homeCurrency: 'JPY',
        homeCountry: 'JP',
        isActive: true
      },
      {
        name: 'Alex Rivera',
        email: 'alex@example.com',
        password: 'password123',
        role: 'user',
        homeCurrency: 'EUR',
        homeCountry: 'ES',
        isActive: true
      }
    ]);
    
    const marcus = users[1];
    console.log('--- 4 USERS CREATED ---');

    // 2. Create Diverse Trips for Marcus
    const trips = await Trip.create([
      {
        userId: marcus._id,
        destination: 'Bali, Indonesia',
        countryCode: 'ID',
        countryName: 'Indonesia',
        startDate: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), 
        endDate: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
        partySize: 2,
        status: 'active',
        coverImage: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
        budget: { amount: 3000, currency: 'USD' },
        checklist: [
          { item: 'Vaccination certificate', category: 'health', checked: true },
          { item: 'Offline Maps downloaded', category: 'documents', checked: true },
          { item: 'Power adapter', category: 'packing', checked: false }
        ]
      },
      {
        userId: marcus._id,
        destination: 'Tokyo, Japan',
        countryCode: 'JP',
        countryName: 'Japan',
        startDate: new Date(Date.now() + 25 * 24 * 60 * 60 * 1000), 
        endDate: new Date(Date.now() + 32 * 24 * 60 * 60 * 1000),
        status: 'planning',
        coverImage: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf',
        budget: { amount: 5000, currency: 'USD' }
      },
      {
        userId: marcus._id,
        destination: 'Swiss Alps',
        countryCode: 'CH',
        countryName: 'Switzerland',
        startDate: new Date(Date.now() + 120 * 24 * 60 * 60 * 1000),
        endDate: new Date(Date.now() + 127 * 24 * 60 * 60 * 1000),
        status: 'planning',
        coverImage: 'https://images.unsplash.com/photo-1531310197839-ccf54634509e'
      }
    ]);
    console.log('--- 3 TRIPS CREATED ---');

    // 3. Create Rich Journal Entries
    await JournalEntry.create([
      {
        userId: marcus._id,
        tripId: trips[0]._id,
        title: 'Sunset at Tanah Lot',
        note: 'The most beautiful sunset I have ever seen. The temple looks surreal against the orange sky.',
        location: { lat: -8.6212, lng: 115.0868, name: 'Tanah Lot', country: 'Indonesia' },
        mood: 'happy',
        weather: { temp: 27, description: 'Golden Hour', icon: '01d' },
        photos: [{ url: 'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2', caption: 'Tanah Lot Sunset' }]
      },
      {
        userId: marcus._id,
        tripId: trips[0]._id,
        title: 'Ubud Monkey Forest',
        note: 'Watch your glasses! One monkey tried to steal my sunglasses. Very clever creatures.',
        location: { lat: -8.5188, lng: 115.2585, name: 'Sacred Monkey Forest', country: 'Indonesia' },
        mood: 'amazing',
        photos: [{ url: 'https://images.unsplash.com/photo-1552611052-33e04de081de', caption: 'Playful monkey' }]
      },
      {
        userId: marcus._id,
        tripId: trips[0]._id,
        title: 'Surfing at Canggu',
        note: 'Caught my first wave today! Exhausted but finally understand the hype.',
        mood: 'happy',
        weather: { temp: 29, description: 'Sunny', icon: '01d' }
      }
    ]);
    console.log('--- 3 JOURNAL ENTRIES CREATED ---');

    // 4. Create Global Favorites
    await Favorite.create([
      {
        userId: marcus._id,
        type: 'restaurant',
        name: 'Sushisamba',
        address: 'London, UK',
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c'
      },
      {
        userId: marcus._id,
        type: 'attraction',
        name: 'Eiffel Tower',
        address: 'Paris, France',
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f'
      },
      {
        userId: marcus._id,
        type: 'hotel',
        name: 'Marina Bay Sands',
        address: 'Singapore',
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1502722823883-da093f71db3a'
      }
    ]);
    console.log('--- 3 FAVORITES CREATED ---');

    console.log('--- ALL DATA SEEDED SUCCESSFULLY ---');
    process.exit(0);
  } catch (err) {
    if (err.errors) {
      Object.keys(err.errors).forEach(key => {
        console.error(`Validation Error on ${key}: ${err.errors[key].message}`);
      });
    } else {
      console.error('ERROR SEEDING DATA:', err);
    }
    process.exit(1);
  }
}

seed();
