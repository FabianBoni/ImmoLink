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