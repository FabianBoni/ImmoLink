const express = require('express');
const router = express.Router();
const { MongoClient, ObjectId } = require('mongodb');
const { dbUri, dbName } = require('../config');

router.get('/available-tenants', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    
    const tenants = await db.collection('users')
      .find({ 
        role: 'tenant',
        propertyId: { $exists: false } 
      })
      .toArray();
    
    console.log(`Found ${tenants.length} available tenants`);
    res.json(tenants);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'Error fetching tenants' });
  } finally {
    await client.close();
  }
});

module.exports = router;