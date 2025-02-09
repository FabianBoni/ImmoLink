const { MongoClient } = require('mongodb');
require('dotenv').config();

// Connection configuration
const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/immolink_db';
const dbName = process.env.DB_NAME || 'immolink_db';

async function initializeDatabase() {
  const client = new MongoClient(uri);

  try {
    await client.connect();
    console.log('Connected to MongoDB');
    const db = client.db(dbName);

    // Users Collection
    await db.createCollection('users', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['email', 'password', 'fullName', 'role', 'birthDate', 'isAdmin', 'isValidated'],
          properties: {
            email: {
              bsonType: 'string',
              pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'
            },
            password: { bsonType: 'string' },
            fullName: { bsonType: 'string' },
            role: { enum: ['landlord', 'tenant'] },
            birthDate: { bsonType: 'date' },
            isAdmin: { bsonType: 'bool' },
            isValidated: { bsonType: 'bool' },
            address: {
              bsonType: 'object',
              required: ['street', 'city', 'postalCode', 'country'],
              properties: {
                street: { bsonType: 'string' },
                city: { bsonType: 'string' },
                postalCode: { bsonType: 'string' },
                country: { bsonType: 'string' }
              }
            }
          }
        }
      }
    });

    // Properties Collection
    await db.createCollection('properties', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['landlordId', 'address', 'status', 'rentAmount'],
          properties: {
            landlordId: { bsonType: 'objectId' },
            tenantIds: { 
              bsonType: 'array',
              items: { bsonType: 'objectId' }
            },
            status: { enum: ['available', 'rented', 'maintenance'] },
            rentAmount: { bsonType: 'double' },
            address: {
              bsonType: 'object',
              required: ['street', 'city', 'postalCode', 'country'],
              properties: {
                street: { bsonType: 'string' },
                city: { bsonType: 'string' },
                postalCode: { bsonType: 'string' },
                country: { bsonType: 'string' }
              }
            },
            details: {
              bsonType: 'object',
              required: ['size', 'rooms'],
              properties: {
                size: { bsonType: 'double' },
                rooms: { bsonType: 'int' },
                amenities: {
                  bsonType: 'array',
                  items: { bsonType: 'string' }
                }
              }
            }
          }
        }
      }
    });

    // Create indexes
    await db.collection('users').createIndex({ email: 1 }, { unique: true });
    await db.collection('properties').createIndex({ landlordId: 1 });
    await db.collection('properties').createIndex({ 'address.postalCode': 1 });
    await db.collection('properties').createIndex({ status: 1 });

    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Database initialization failed:', error);
    throw error;
  } finally {
    await client.close();
  }
}

// Execute initialization
initializeDatabase().catch(console.error);