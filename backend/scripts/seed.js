const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const CountryGuide = require('../models/CountryGuide');

const countries = [
  {
    name: 'Japan',
    countryCode: 'JP',
    flagUrl: 'https://flagcdn.com/w320/jp.png',
    coverImage: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=1200',
    description: 'Japan is an island country in East Asia. It is situated in the northwest Pacific Ocean and is bordered on the west by the Sea of Japan.',
    bestTimeToVisit: 'March to May & September to November',
    language: 'Japanese',
    currency: 'JPY (¥)',
    featured: true,
    tips: ['Get a JR Pass', 'Try sushi at a local market', 'Respect silence in public transport']
  },
  {
    name: 'France',
    countryCode: 'FR',
    flagUrl: 'https://flagcdn.com/w320/fr.png',
    coverImage: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=1200',
    description: 'France, in Western Europe, encompasses medieval cities, alpine villages and Mediterranean beaches.',
    bestTimeToVisit: 'Spring (April to June) or Autumn (September to October)',
    language: 'French',
    currency: 'EUR (€)',
    featured: true,
    tips: ['Learn basic French phrases', 'Check museum hours', 'Enjoy the café culture']
  },
  {
    name: 'Thailand',
    countryCode: 'TH',
    flagUrl: 'https://flagcdn.com/w320/th.png',
    coverImage: 'https://images.unsplash.com/photo-1528181304800-259b08848526?q=80&w=1200',
    description: 'Thailand is a Southeast Asian country known for tropical beaches, ancient ruins and ornate temples.',
    bestTimeToVisit: 'November to February',
    language: 'Thai',
    currency: 'THB (฿)',
    featured: true,
    tips: ['Try street food', 'Dress modestly in temples', 'Use Grab app for transport']
  }
];

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');
    
    await CountryGuide.deleteMany({});
    console.log('Cleared existing guides');
    
    await CountryGuide.insertMany(countries);
    console.log('Successfully seeded ' + countries.length + ' countries');
    
    process.exit(0);
  } catch (err) {
    console.error('Seed failed:', err);
    process.exit(1);
  }
};

seed();
