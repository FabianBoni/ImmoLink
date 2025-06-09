const express = require('express');
const router = express.Router();
const { MongoClient, ObjectId } = require('mongodb');
const { dbUri, dbName } = require('../config');

// Get all available tenants (not assigned to any property)
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

// Get all tenants
router.get('/tenants', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    
    // Get all tenants
    const tenants = await db.collection('users')
      .find({ role: 'tenant' })
      .toArray();
    
    // Find properties for each tenant to include property information
    const tenantsWithProperties = await Promise.all(
      tenants.map(async (tenant) => {
        const properties = await db.collection('properties')
          .find({ 
            tenantIds: tenant._id.toString() 
          })
          .toArray();
        
        const propertyAddresses = properties.map(prop => 
          `${prop.address.street}, ${prop.address.city}`
        );
        
        return {
          ...tenant,
          properties: propertyAddresses,
          phone: tenant.phone || '',
          // Add tenant status based on property assignment
          status: properties.length > 0 ? 'active' : 'available'
        };
      })
    );
    
    console.log(`Found ${tenantsWithProperties.length} total tenants`);
    res.json(tenantsWithProperties);
  } catch (error) {
    console.error('Error fetching all tenants:', error);
    res.status(500).json({ message: 'Error fetching tenants' });
  } finally {
    await client.close();
  }
});

// Get all users (for general use)
router.get('/', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    
    const users = await db.collection('users')
      .find({})
      .toArray();
    
    console.log(`Found ${users.length} total users`);
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ message: 'Error fetching users' });
  } finally {
    await client.close();
  }
});

module.exports = router;