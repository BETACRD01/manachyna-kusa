import 'dart:async';
import '../../core/utils/app_logger.dart';
import 'base_api_service.dart';

/// DatabaseService acts as a generic bridge to the Django REST API.
/// It replaces the old Supabase-based implementation.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final BaseApiService _apiService = BaseApiService();

  // ====== GENERIC CRUD (REST Mapped) =========================================

  Future<Map<String, dynamic>?> getDocument(String resource, String id) async {
    try {
      return await _apiService.get('$resource/$id/');
    } catch (e) {
      AppLogger.e('Error getting $resource/$id: $e');
      return null;
    }
  }

  Future<String> createDocument(String resource, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('$resource/', body: data);
      return response['id'].toString();
    } catch (e) {
      AppLogger.e('Error creating $resource: $e');
      rethrow;
    }
  }

  Future<void> updateDocument(String resource, String id, Map<String, dynamic> data) async {
    try {
      await _apiService.put('$resource/$id/', body: data);
    } catch (e) {
      AppLogger.e('Error updating $resource/$id: $e');
      rethrow;
    }
  }

  Future<void> deleteDocument(String resource, String id) async {
    try {
      await _apiService.delete('$resource/$id/');
    } catch (e) {
      AppLogger.e('Error deleting $resource/$id: $e');
      rethrow;
    }
  }

  // ====== SERVICES ==========================================================

  Future<List<Map<String, dynamic>>> getAllActiveServices() async {
    try {
      final response = await _apiService.get('services/');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFeaturedServices() async {
    try {
      final response = await _apiService.get('services/featured/');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchServices(String term) async {
    try {
      final response = await _apiService.get('services/search/?q=$term');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getProviderServices(String providerId) {
    // Returning a stream that fetches once for compatibility with existing UI
    return Stream.fromFuture(_apiService.get('providers/$providerId/services/')
        .then((response) => List<Map<String, dynamic>>.from(response))
        .catchError((_) => <Map<String, dynamic>>[]));
  }

  Future<void> updateServiceStatus(String serviceId, bool isActive) async {
    await _apiService.patch('services/$serviceId/', body: {'isActive': isActive});
  }

  Future<void> deleteService(String serviceId) async {
    await _apiService.delete('services/$serviceId/');
  }

  Future<void> createService(Map<String, dynamic> data) async {
    await _apiService.post('services/', body: data);
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    await _apiService.put('services/$serviceId/', body: data);
  }

  // ====== PROVIDERS ==========================================================

  Future<Map<String, dynamic>?> getProviderProfile(String providerId) async {
    return getDocument('providers', providerId);
  }

  Future<List<Map<String, dynamic>>> getVerifiedProviders() async {
    try {
      final response = await _apiService.get('providers/verified/');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProviderBookings(String providerId, [String? status]) async {
    try {
      String url = 'bookings/?provider_id=$providerId';
      if (status != null) {
        url += '&status=$status';
      }
      final response = await _apiService.get(url);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getActiveUserBookings(String userId) async {
    try {
      final response = await _apiService.get('bookings/active/');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await updateDocument('bookings', bookingId, {'status': newStatus});
  }

  // ====== STATS ==============================================================

  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    try {
      return await _apiService.get('users/stats/');
    } catch (e) {
      return {
        'totalBookings': 0,
        'completedBookings': 0,
        'pendingBookings': 0,
        'totalSpent': 0.0,
      };
    }
  }

  // ====== ADMIN / REQUESTS ======
  Future<List<Map<String, dynamic>>> getProviderRequests({String? status}) async {
    try {
      final url = status != null ? 'admin/requests/?status=$status' : 'admin/requests/';
      final response = await _apiService.get(url);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> updateProviderRequestStatus(String requestId, String status) async {
    await _apiService.patch('admin/requests/$requestId/', body: {'status': status});
  }

  Future<void> createProviderRequest(Map<String, dynamic> data) async {
    await _apiService.post('requests/', body: data);
  }

  // ====== SERVICES ======
  Future<Map<String, dynamic>?> getServiceById(String serviceId) async {
    return getDocument('services', serviceId);
  }

  // ====== BOOKINGS (CLIENT) ======
  Future<List<Map<String, dynamic>>> getClientBookings(String userId) async {
    try {
      final response = await _apiService.get('bookings/?client_id=$userId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getClientBookingsByStatus(String userId, String status) async {
    try {
      final response = await _apiService.get('bookings/?client_id=$userId&status=$status');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getClientRecentBookings(String userId) async {
    try {
      final response = await _apiService.get('bookings/?client_id=$userId&limit=5');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    await deleteDocument('bookings', bookingId);
  }

  // ====== PAYMENTS ======
  Future<List<Map<String, dynamic>>> getMonthlyPayments(String userId) async {
    try {
      final response = await _apiService.get('payments/monthly/?user_id=$userId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserPaymentMethods(String userId) async {
    try {
      final response = await _apiService.get('payments/methods/?user_id=$userId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentPayments(String userId) async {
    try {
      final response = await _apiService.get('payments/recent/?user_id=$userId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    await _apiService.patch('payments/methods/$methodId/', body: {'isDefault': true});
  }

  Future<void> deletePaymentMethod(String methodId) async {
    await _apiService.delete('payments/methods/$methodId/');
  }

  Future<void> addPaymentMethod(Map<String, dynamic> data) async {
    await _apiService.post('payments/methods/', body: data);
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      final response = await _apiService.get('payments/history/?user_id=$userId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> reportProblem(Map<String, dynamic> data) async {
    await _apiService.post('reports/', body: data);
  }

  // ====== COMPATIBILITY LAYER ================================================
  // Streams are replaced with Future lists for now, as Django uses standard REST.
  // In a future phase, we can integrate WebSockets (Django Channels).

  Stream<List<Map<String, dynamic>>> getAllActiveServicesStream() => 
      Stream.fromFuture(getAllActiveServices());

  Stream<List<Map<String, dynamic>>> getProvidersRealTimeStream() => 
      Stream.fromFuture(getVerifiedProviders());
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('bookings/', body: data);
      return response;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<void> updateProviderStats(String providerId, Map<String, dynamic> data) async {
    try {
      await _apiService.patch('users/providers/$providerId/', body: data);
    } catch (e) {
      // Ignorar stat error
    }
  }

  Future<void> createNotification(Map<String, dynamic> data) async {
    try {
      await _apiService.post('notifications/', body: data);
    } catch (e) {
      // Ignorar stat error
    }
  }

  Future<List<Map<String, dynamic>>> getProviders() async {
    try {
      final response = await _apiService.get('users/providers/');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
