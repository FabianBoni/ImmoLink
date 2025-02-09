const express = require('express');
const router = express.Router();
const { MongoClient } = require('mongodb');
const { dbUri, dbName } = require('../config');

router.get('/landlord/:landlordId', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    
    const properties = await db.collection('properties')
      .find({ landlordId: req.params.landlordId })
      .toArray();
      
    const propertyIds = properties.map(p => p._id);
    
    const tenants = await db.collection('users')
      .find({ 
        role: 'tenant',
        propertyId: { $in: propertyIds }
      })
      .toArray();
      
    res.json({ properties, tenants });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching properties' });
  } finally {
    await client.close();
  }
});

// New POST route for property creation
router.post('/', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    // Transform incoming data to match schema
    const propertyData = {
      landlordId: req.body.landlordId,
      address: {
        street: req.body.address.street,
        city: req.body.address.city,
        postalCode: req.body.address.postalCode,
        country: req.body.address.country
      },
      status: req.body.status,
      rentAmount: Number(req.body.rentAmount),
      details: {
        size: Number(req.body.details.size),
        rooms: Number(req.body.details.rooms),
        amenities: req.body.details.amenities
      },
      imageUrls: req.body.imageUrls || [],
      tenantIds: req.body.tenantIds || [],
      outstandingPayments: Number(req.body.outstandingPayments) || 0,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    await client.connect();
    const db = client.db(dbName);
    
    console.log('Final property data:', JSON.stringify(propertyData, null, 2));
    const result = await db.collection('properties').insertOne(propertyData);
    
    res.status(201).json({
      success: true,
      propertyId: result.insertedId,
      property: propertyData
    });

  } catch (error) {
    console.error('Property creation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create property',
      error: error.message
    });
  } finally {
    await client.close();
  }
});
module.exports = router;