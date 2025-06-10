import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/invitation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/api_constants.dart';

// Service provider for invitation operations
final invitationServiceProvider = Provider<InvitationService>((ref) {
  return InvitationService();
});

class InvitationService {
  static const String _apiUrl = ApiConstants.baseUrl;

  Future<List<Invitation>> getUserInvitations(String userId) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/invitations/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Invitation.fromMap(json)).toList();
    }
    throw Exception('Failed to fetch invitations');
  }

  Future<void> respondToInvitation(String invitationId, String response) async {
    final httpResponse = await http.put(
      Uri.parse('$_apiUrl/invitations/$invitationId/respond'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'response': response}),
    );

    if (httpResponse.statusCode != 200) {
      throw Exception('Failed to respond to invitation');
    }
  }

  Future<void> sendInvitation({
    required String propertyId,
    required String landlordId,
    required String tenantId,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/invitations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'propertyId': propertyId,
        'landlordId': landlordId,
        'tenantId': tenantId,
        'message': message ?? 'You have been invited to rent this property',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send invitation');
    }
  }
}

// Provider for current user's invitations
final userInvitationsProvider = FutureProvider<List<Invitation>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return [];
  }

  final invitationService = ref.watch(invitationServiceProvider);
  return invitationService.getUserInvitations(currentUser.id);
});

// Provider for pending invitations only
final pendingInvitationsProvider = Provider<AsyncValue<List<Invitation>>>((ref) {
  final invitationsAsync = ref.watch(userInvitationsProvider);
  
  return invitationsAsync.when(
    data: (invitations) => AsyncValue.data(
      invitations.where((invitation) => invitation.isPending).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// State notifier for invitation actions
class InvitationNotifier extends StateNotifier<AsyncValue<void>> {
  final InvitationService _invitationService;
  final Ref _ref;

  InvitationNotifier(this._invitationService, this._ref) 
      : super(const AsyncValue.data(null));

  Future<void> respondToInvitation(String invitationId, String response) async {
    state = const AsyncValue.loading();
    
    try {
      await _invitationService.respondToInvitation(invitationId, response);
      state = const AsyncValue.data(null);
      
      // Refresh invitations after responding
      _ref.invalidate(userInvitationsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendInvitation({
    required String propertyId,
    required String landlordId,
    required String tenantId,
    String? message,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _invitationService.sendInvitation(
        propertyId: propertyId,
        landlordId: landlordId,
        tenantId: tenantId,
        message: message,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final invitationNotifierProvider = StateNotifierProvider<InvitationNotifier, AsyncValue<void>>((ref) {
  return InvitationNotifier(ref.watch(invitationServiceProvider), ref);
});
