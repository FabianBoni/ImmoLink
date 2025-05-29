const { MongoClient } = require('mongodb');
const { dbUri, dbName } = require('../config');
const propertySchema = require('../models/property_schema');

async function updatePropertySchema() {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    console.log('Connected to MongoDB');
    
    const db = client.db(dbName);
    console.log('Database selected:', dbName);
    
    // Check if the collection exists
    const collections = await db.listCollections({ name: 'properties' }).toArray();
    if (collections.length === 0) {
      console.log('Creating properties collection...');
      await db.createCollection('properties', propertySchema);
    } else {
      console.log('Properties collection exists, updating validation...');
      
      // Drop the collection and recreate with validation
      try {
        await db.collection('properties').drop();
        console.log('Dropped existing collection');
      } catch (error) {
        console.log('Collection may not exist:', error.message);
      }
      
      // Create collection with validation
      await db.createCollection('properties', propertySchema);
    }
    
    console.log('Property schema updated successfully');
  } catch (error) {
    console.error('Error updating schema:', error);
  } finally {
    await client.close();
  }
}

updatePropertySchema();