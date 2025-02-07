const { MongoClient } = require('mongodb');

const uri = 'mongodb+srv://immolink_service:CekXrtrJhJLj4sWx@cluster0.h6adx.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
const dbName = 'immolink_db';

async function initializeDatabase() {
  const client = new MongoClient(uri);

  try {
    await client.connect();
    console.log('Connected to MongoDB Atlas');

    const db = client.db(dbName);

    // Users Collection
    await db.createCollection('users', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['email', 'fullName', 'birthDate', 'role', 'isAdmin', 'isValidated', 'address'],
          properties: {
            email: {
              bsonType: 'string',
              pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'
            },
            fullName: {
              bsonType: 'string',
              minLength: 2
            },
            birthDate: {
              bsonType: 'date'
            },
            role: {
              enum: ['landlord', 'customer']
            },
            isAdmin: {
              bsonType: 'bool'
            },
            isValidated: {
              bsonType: 'bool'
            },
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
          required: ['landlordId', 'address', 'type', 'price', 'status'],
          properties: {
            landlordId: { bsonType: 'objectId' },
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
            type: {
              enum: ['apartment', 'house', 'commercial']
            },
            price: {
              bsonType: 'decimal'
            },
            status: {
              enum: ['available', 'rented', 'maintenance']
            },
            amenities: {
              bsonType: 'array',
              items: { bsonType: 'string' }
            }
          }
        }
      }
    });

    // Service Providers Collection
    await db.createCollection('serviceProviders', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['name', 'services', 'contact', 'isVerified'],
          properties: {
            name: { bsonType: 'string' },
            services: {
              bsonType: 'array',
              items: { bsonType: 'string' }
            },
            contact: {
              bsonType: 'object',
              required: ['email', 'phone'],
              properties: {
                email: { bsonType: 'string' },
                phone: { bsonType: 'string' }
              }
            },
            isVerified: { bsonType: 'bool' },
            rating: { bsonType: 'decimal' }
          }
        }
      }
    });

    // Services Collection
    await db.createCollection('services', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['propertyId', 'providerId', 'type', 'status', 'scheduledDate'],
          properties: {
            propertyId: { bsonType: 'objectId' },
            providerId: { bsonType: 'objectId' },
            type: {
              enum: ['maintenance', 'cleaning', 'repair', 'inspection']
            },
            status: {
              enum: ['scheduled', 'in_progress', 'completed', 'cancelled']
            },
            scheduledDate: { bsonType: 'date' },
            completionDate: { bsonType: 'date' },
            cost: { bsonType: 'decimal' }
          }
        }
      }
    });

    // Create indexes
    await db.collection('users').createIndex({ email: 1 }, { unique: true });
    await db.collection('properties').createIndex({ landlordId: 1 });
    await db.collection('services').createIndex({ propertyId: 1 });
    await db.collection('services').createIndex({ providerId: 1 });
    await db.collection('serviceProviders').createIndex({ 'contact.email': 1 }, { unique: true });

    console.log('Database initialization completed successfully');
  } finally {
    await client.close();
  }
}

initializeDatabase().catch(console.error);