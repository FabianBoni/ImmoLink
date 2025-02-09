const propertySchema = {
  id: ObjectId,
  landlordId: ObjectId,
  tenantIds: [ObjectId],
  address: {
    street: String,
    city: String,
    postalCode: String,
    country: String
  },
  status: String, // 'available', 'rented', 'maintenance'
  rentAmount: Number,
  details: {
    size: Number,
    rooms: Number,
    amenities: [String]
  }
}
