const propertySchema = {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["landlordId", "address", "status", "rentAmount"],
      properties: {
        landlordId: {
          bsonType: "string",
          description: "Unique identifier for the landlord"
        },
        address: {
          bsonType: "object",
          required: ["street", "city", "postalCode", "country"],
          properties: {
            street: { bsonType: "string" },
            city: { bsonType: "string" },
            postalCode: { bsonType: "string" },
            country: { bsonType: "string" }
          }
        },
        status: {
          enum: ["available", "rented", "maintenance"],
          description: "Property status"
        },
        rentAmount: {
          bsonType: ["int", "double"],
          minimum: 0
        },
        details: {
          bsonType: "object",
          required: ["size", "rooms", "amenities"],
          properties: {
            size: { 
              bsonType: ["int", "double"],
              minimum: 0 
            },
            rooms: { 
              bsonType: ["int", "double"],
              minimum: 0 
            },
            amenities: {
              bsonType: "array",
              items: { bsonType: "string" }
            }
          }
        },
        imageUrls: {
          bsonType: "array",
          items: { bsonType: "string" }
        },
        tenantIds: {
          bsonType: "array",
          items: { bsonType: "string" }
        },
        outstandingPayments: { 
          bsonType: ["int", "double"],
          minimum: 0 
        },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      }
    }
  }
};

module.exports = propertySchema;