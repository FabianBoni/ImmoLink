import 'package:immolink/core/services/database_service.dart';
import 'package:immolink/features/payment/domain/models/payment.dart';

class PaymentService {
  final DatabaseService _databaseService = DatabaseService.instance;
  final String _collectionName = 'payments';

  Future<List<Payment>> getPaymentsByTenant(String tenantId) async {
    final result = await _databaseService.find(
      _collectionName,
      {'tenantId': tenantId},
    );

    return result.map((doc) => Payment.fromMap(doc)).toList();
  }

  Future<List<Payment>> getPaymentsByProperty(String propertyId) async {
    final result = await _databaseService.find(
      _collectionName,
      {'propertyId': propertyId},
    );

    return result.map((doc) => Payment.fromMap(doc)).toList();
  }

  Future<List<Payment>> getPaymentsByLandlord(String landlordId) async {
    // First get all properties owned by this landlord
    final properties = await _databaseService.find(
      'properties',
      {'landlordId': landlordId},
    );

    final propertyIds = properties.map((p) => p['_id'].toString()).toList();

    // Then get all payments for these properties
    final result = await _databaseService.find(
      _collectionName,
      {'propertyId': {'\$in': propertyIds}},
    );

    return result.map((doc) => Payment.fromMap(doc)).toList();
  }

  Future<Payment> getPaymentById(String id) async {
    final result = await _databaseService.findOne(
      _collectionName,
      {'_id': id},
    );

    return Payment.fromMap(result);
  }

  Future<Payment> createPayment(Payment payment) async {
    final result = await _databaseService.insertOne(
      _collectionName,
      payment.toMap(),
    );

    return Payment.fromMap(result);
  }

  Future<Payment> updatePayment(Payment payment) async {
    final result = await _databaseService.updateOne(
      _collectionName,
      {'_id': payment.id},
      {'\$set': payment.toMap()},
    );

    return Payment.fromMap(result);
  }

  Future<void> deletePayment(String id) async {
    await _databaseService.deleteOne(
      _collectionName,
      {'_id': id},
    );
  }
}
