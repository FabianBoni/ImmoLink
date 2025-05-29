import 'package:immolink/core/services/database_service.dart';
import 'package:immolink/features/maintenance/domain/models/maintenance_request.dart';

class MaintenanceService {
  final DatabaseService _databaseService = DatabaseService.instance;
  final String _collectionName = 'maintenance_requests';

  Future<List<MaintenanceRequest>> getMaintenanceRequestsByTenant(String tenantId) async {
    final result = await _databaseService.find(
      _collectionName,
      {'tenantId': tenantId},
    );

    return result.map((doc) => MaintenanceRequest.fromMap(doc)).toList();
  }

  Future<List<MaintenanceRequest>> getMaintenanceRequestsByProperty(String propertyId) async {
    final result = await _databaseService.find(
      _collectionName,
      {'propertyId': propertyId},
    );

    return result.map((doc) => MaintenanceRequest.fromMap(doc)).toList();
  }

  Future<List<MaintenanceRequest>> getMaintenanceRequestsByLandlord(String landlordId) async {
    // First get all properties owned by this landlord
    final properties = await _databaseService.find(
      'properties',
      {'landlordId': landlordId},
    );

    final propertyIds = properties.map((p) => p['_id'].toString()).toList();

    // Then get all maintenance requests for these properties
    final result = await _databaseService.find(
      _collectionName,
      {'propertyId': {'\$in': propertyIds}},
    );

    return result.map((doc) => MaintenanceRequest.fromMap(doc)).toList();
  }

  Future<MaintenanceRequest> getMaintenanceRequestById(String id) async {
    final result = await _databaseService.findOne(
      _collectionName,
      {'_id': id},
    );

    return MaintenanceRequest.fromMap(result);
  }

  Future<MaintenanceRequest> createMaintenanceRequest(MaintenanceRequest request) async {
    final result = await _databaseService.insertOne(
      _collectionName,
      request.toMap(),
    );

    return MaintenanceRequest.fromMap(result);
  }

  Future<MaintenanceRequest> updateMaintenanceRequest(MaintenanceRequest request) async {
    final result = await _databaseService.updateOne(
      _collectionName,
      {'_id': request.id},
      {'\$set': request.toMap()},
    );

    return MaintenanceRequest.fromMap(result);
  }

  Future<void> deleteMaintenanceRequest(String id) async {
    await _databaseService.deleteOne(
      _collectionName,
      {'_id': id},
    );
  }
}
