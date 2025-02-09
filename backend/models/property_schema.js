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
          bsonType: "number",
          minimum: 0
        },
        details: {
          bsonType: "object",
          required: ["size", "rooms", "amenities"],
          properties: {
            size: { bsonType: "number" },
            rooms: { bsonType: "number" },
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
        outstandingPayments: { bsonType: "number" },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      }
    }
  }
};