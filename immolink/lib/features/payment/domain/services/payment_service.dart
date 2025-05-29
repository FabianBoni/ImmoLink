import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:immolink/features/payment/domain/models/payment.dart';
import 'package:immolink/core/config/db_config.dart';

class PaymentService {
  final String _apiUrl = DbConfig.apiUrl;

  Future<List<Payment>> getPaymentsByTenant(String tenantId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/payments/tenant/$tenantId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Payment.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  Future<List<Payment>> getPaymentsByProperty(String propertyId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/payments/property/$propertyId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Payment.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  Future<List<Payment>> getPaymentsByLandlord(String landlordId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/payments/landlord/$landlordId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Payment.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  Future<Payment> getPaymentById(String id) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/payments/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Payment.fromMap(data);
    } else {
      throw Exception('Failed to load payment');
    }
  }

  Future<Payment> createPayment(Payment payment) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/payments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payment.toMap()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Payment.fromMap(data);
    } else {
      throw Exception('Failed to create payment');
    }
  }

  Future<Payment> updatePayment(Payment payment) async {
    final response = await http.put(
      Uri.parse('$_apiUrl/payments/${payment.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payment.toMap()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Payment.fromMap(data);
    } else {
      throw Exception('Failed to update payment');
    }
  }

  Future<void> deletePayment(String id) async {
    final response = await http.delete(
      Uri.parse('$_apiUrl/payments/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete payment');
    }
  }
}
