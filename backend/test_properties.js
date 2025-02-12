const { MongoClient } = require('mongodb');
const { dbUri, dbName } = require('./config');

async function testQuery() {
    const client = new MongoClient(dbUri);
    const landlordId = "67a9240fb78266daba48fee4";

    try {
        await client.connect();
        const db = client.db(dbName);
        
        console.log('Running test query for landlordId:', landlordId);
        
        const properties = await db.collection('properties')
            .find({ landlordId: landlordId })
            .toArray();
        
        console.log('Found properties:', properties.length);
        console.log('Properties:', JSON.stringify(properties, null, 2));

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await client.close();
    }
}

testQuery();