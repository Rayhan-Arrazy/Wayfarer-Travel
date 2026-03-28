const mongoose = require('mongoose');
const User = require('./models/User');
const Trip = require('./models/Trip');
const JournalEntry = require('./models/JournalEntry');
const Favorite = require('./models/Favorite');
const CountryGuide = require('./models/CountryGuide');
const Notification = require('./models/Notification');
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
    await CountryGuide.deleteMany({});
    await Notification.deleteMany({});
    console.log('--- CLEARED ALL 6 COLLECTIONS ---');

    // 1. Create Users
    const users = await User.create([
      {
        name: 'Alex Rivers',
        email: 'alex@wayfarer.com',
        password: 'password123',
        role: 'user',
        homeCurrency: 'USD',
        homeCountry: 'US',
        isActive: true,
      },
      {
        name: 'Elias Rivera',
        email: 'elias@wayfarer.com',
        password: 'password123',
        role: 'user',
        homeCurrency: 'EUR',
        homeCountry: 'ES',
        isActive: true,
        visitedCountries: ['PT', 'ES', 'FR'],
      },
      {
        name: 'Sarah Jenkins',
        email: 'admin@wayfarer.com',
        password: 'password123',
        role: 'admin',
        homeCurrency: 'USD',
        homeCountry: 'US',
        isActive: true,
      }
    ]);

    const [alex, elias, sarah] = users;
    console.log('--- USERS CREATED (Elias included) ---');

    // 2. Create Trips
    const trips = await Trip.create([
      {
        userId: elias._id,
        destination: 'Madeira, Portugal',
        countryCode: 'PT',
        countryName: 'Portugal',
        startDate: new Date('2023-10-22'),
        endDate: new Date('2023-10-29'),
        partySize: 2,
        status: 'active',
        coverImage: 'https://images.unsplash.com/photo-1551020485-ec947df31566?w=1200',
        budget: { amount: 2500, currency: 'EUR' },
        expenses: [
          { title: 'Dinner - Stockholm Bistro', amount: 54.20, date: new Date('2023-10-23T20:15:00'), category: 'Food' },
          { title: 'Museum Entrance - Vasa', amount: 18.00, date: new Date('2023-10-23T14:30:00'), category: 'Entertainment' },
          { title: 'Train Ticket - SJ Rail', amount: 125.50, date: new Date('2023-10-22T09:00:00'), category: 'Transport' }
        ],
        itinerary: [
          { 
            title: 'Levada do Caldeirão Verde Hike', 
            time: '14:00', 
            date: new Date('2023-10-24'), 
            location: 'Santana, Madeira',
            checked: false 
          }
        ],
        destinationInfo: { currency: 'EUR', language: 'Portuguese', timezone: 'Atlantic/Madeira', capital: 'Funchal', population: 265000, flagUrl: 'https://flagcdn.com/w320/pt.png' }
      },
      {
        userId: elias._id,
        destination: 'Kyoto, Japan',
        countryCode: 'JP',
        countryName: 'Japan',
        startDate: new Date('2023-12-10'),
        endDate: new Date('2023-12-20'),
        partySize: 1,
        status: 'planning',
        coverImage: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800',
        budget: { amount: 3000, currency: 'EUR' },
        expenses: [],
      }
    ]);
    console.log(`--- ${trips.length} TRIPS CREATED ---`);

    // 3. Create Journal Entries
    await JournalEntry.create([
      {
        userId: elias._id,
        tripId: trips[0]._id,
        title: 'Summit of Pico do Arieiro',
        note: 'The air at the summit of Pico do Arieiro felt like ice, but the sunrise broke through the clouds in shards of liquid gold.',
        location: { lat: 32.7355, lng: -16.9287, name: 'Pico do Arieiro', country: 'Portugal' },
        mood: 'Amazing',
        weather: { temp: 4, description: 'Frozen Sunrise', icon: '01d' },
        photos: [{ url: 'https://images.unsplash.com/photo-1551020485-ec947df31566', caption: 'Above the clouds' }],
        distanceTraveled: 12.5,
      },
      {
        userId: elias._id,
        tripId: trips[0]._id,
        title: 'A Quiet Morning in Gion',
        note: 'The morning mist was still clinging to the wooden facades of the tea houses. I found a small bench near the Tatsumi Bridge and just listened to the water.',
        location: { lat: 35.0037, lng: 135.7785, name: 'Gion District', country: 'Japan' },
        mood: 'Adventurous',
        weather: { temp: 12, description: 'Foggy Morning', icon: '50d' },
      }
    ]);
    console.log('--- JOURNAL ENTRIES CREATED ---');

    // 4. Create Favorites
    await Favorite.create([
      {
        userId: alex._id, type: 'restaurant', name: 'Sushisamba',
        address: 'Bishopsgate, London, UK', rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c',
        location: { lat: 51.5204, lng: -0.0794 },
      }
    ]);

    // 5. Create Country Guides
    await CountryGuide.create([
      {
        name: 'Japan',
        countryCode: 'JP',
        description: 'A blend of ancient traditions and futuristic technology.',
        flagUrl: 'https://flagcdn.com/w320/jp.png',
        coverImage: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e',
        tips: ['Get a JR Pass', 'Respect local etiquette'],
        featured: true
      },
      {
        name: 'Kyoto, Japan',
        countryCode: 'JP',
        description: 'Explore Culture & Tips — A tapestry of ancient traditions...',
        flagUrl: 'https://flagcdn.com/w320/jp.png',
        coverImage: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e',
        tips: ['Kyoto is the spiritual heart'],
        featured: true
      }
    ]);
    console.log('--- GUIDES CREATED ---');

    console.log('--- SEEDING COMPLETE ---');
    process.exit(0);
  } catch (err) {
    console.error('ERROR SEEDING DATA:', err);
    process.exit(1);
  }
}

seed();
