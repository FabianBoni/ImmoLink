const { MongoClient } = require('mongodb');
const { dbUri, dbName } = require('../config');
const propertySchema = require('../models/property_schema');

async function initializeCollection() {
  const client = new MongoClient(dbUri);
  try {
    await client.connect();
    const db = client.db(dbName);
    
    // Drop existing collection if it exists
    try {
      await db.collection('properties').drop();
    } catch (e) {
      // Collection might not exist, continue
    }

    // Create new collection with schema
    await db.createCollection('properties', {
      validator: propertySchema.validator
    });
    
    console.log('Properties collection created with schema validation');
  } finally {
    await client.close();
  }
}

initializeCollection();