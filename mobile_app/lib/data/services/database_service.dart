import 'dart:async';

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final Logger logger = Logger();

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  final StreamController<Map<String, dynamic>> _providerChangesController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get providerChangesStream =>
      _providerChangesController.stream;

  // ====== HELPERS ============================================================

  void _triggerProviderChangeEvent(String type, String providerId,
      {Map<String, dynamic>? data}) {
    final event = {
      'type': type,
      'providerId': providerId,
      'timestamp': DateTime.now().toIso8601String(),
      'data': data ?? {},
    };
    _providerChangesController.add(event);
    logger.i('Evento de cambio disparado: $type para $providerId');
  }

  // ====== BASE (CRUD genérico) ==============================================

  Future<Map<String, dynamic>?> getDocument(String table, String id) async {
    try {
      final response =
          await _supabase.from(table).select().eq('id', id).single();
      return response;
    } catch (e) {
      // return null if not found
      return null;
    }
  }

  Future<String> createDocument(String table, Map<String, dynamic> data) async {
    try {
      // Ensure data has timestamps
      final now = DateTime.now().toIso8601String();
      final insertData = {
        ...data,
        'createdAt': data['createdAt'] ?? now,
        'updatedAt': now,
      };
      // If no ID provided, Supabase (Postgres) usually auto-generates if configured as uuid default gen,
      // but standard Supabase Flutter insert doesn't return ID unless we select it.
      // .select() returns the inserted row.
      final response =
          await _supabase.from(table).insert(insertData).select().single();
      return response['id'].toString();
    } catch (e) {
      logger.e('Error creating document in $table: $e');
      rethrow;
    }
  }

  Future<void> updateDocument(
      String table, String id, Map<String, dynamic> data) async {
    try {
      final updateData = {
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _supabase.from(table).update(updateData).eq('id', id);
    } catch (e) {
      logger.e('Error updating document $id in $table: $e');
      rethrow;
    }
  }

  Future<void> deleteDocument(String table, String id) async {
    try {
      await _supabase.from(table).delete().eq('id', id);
    } catch (e) {
      logger.e('Error deleting document $id from $table: $e');
      rethrow;
    }
  }

  // ====== SERVICIOS ==========================================================

  Stream<List<Map<String, dynamic>>> getAllActiveServices() {
    return _supabase.from('services').stream(primaryKey: ['id']).map((list) {
      return list; // Assuming we want all, filtering usually handled by query if possible or client side
    });
  }

  Stream<List<Map<String, dynamic>>> getFeaturedServices() {
    return _supabase
        .from('services')
        .stream(primaryKey: ['id'])
        .order('rating', ascending: false)
        .limit(6)
        .map((list) => list
            .where((s) => s['isActive'] == true && s['isAvailable'] == true)
            .toList());
  }

  Stream<List<Map<String, dynamic>>> searchServices(String term) {
    // Supabase stream text search is hard.
    // We will standard filtered stream or just fetch.
    // For "Search", usually a Future is better, but if we need Stream:
    return _supabase.from('services').stream(primaryKey: ['id']).map((list) {
      final s = term.toLowerCase();
      return list.where((item) {
        final keywords = List<String>.from(item['searchKeywords'] ?? []);
        return item['isActive'] == true && keywords.any((k) => k.contains(s));
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getProviderServices(String providerId) {
    return _supabase
        .from('services')
        .stream(primaryKey: ['id']).eq('providerId', providerId);
  }

  Future<String> createService(Map<String, dynamic> data) async {
    final id = await createDocument('services', data);
    final providerId = data['providerId'] as String?;
    if (providerId != null) {
      _triggerProviderChangeEvent('service_created', providerId, data: {
        'serviceId': id,
        'serviceName': data['title'] ?? data['name'],
      });
    }
    return id;
  }

  Future<void> updateService(
      String serviceId, Map<String, dynamic> data) async {
    await updateDocument('services', serviceId, data);

    // Fetch providerId to notify
    // In a real app we might optimize this, but for now fetch
    final s = await getDocument('services', serviceId);
    if (s != null) {
      final providerId = s['providerId'];
      _triggerProviderChangeEvent('service_updated', providerId, data: {
        'serviceId': serviceId,
        'serviceName': data['title'] ?? data['name'],
      });
    }
  }

  Future<void> updateServiceStatus(String serviceId, bool isActive) async {
    await updateDocument('services', serviceId, {'isActive': isActive});

    final s = await getDocument('services', serviceId);
    if (s != null) {
      final providerId = s['providerId'];
      _triggerProviderChangeEvent('service_status_updated', providerId, data: {
        'serviceId': serviceId,
        'serviceName': s['title'] ?? s['name'],
        'isActive': isActive,
      });
    }
  }

  Future<void> deleteService(String serviceId) async {
    final s = await getDocument('services', serviceId);
    await deleteDocument('services', serviceId);

    if (s != null) {
      _triggerProviderChangeEvent('service_deleted', s['providerId'], data: {
        'serviceId': serviceId,
        'serviceName': s['title'] ?? s['name'],
      });
    }
  }

  Future<void> deleteServiceImage(String imageUrl) async {
    try {
      // Extract path from URL if it is Supabase URL
      // Assuming standard buckets
      if (imageUrl.contains('storage/v1/object/public/')) {
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        // .../bucket/path/to/file
        // segments: [storage, v1, object, public, bucket, folder, file]
        if (pathSegments.length > 4) {
          final bucket = pathSegments[4];
          final path = pathSegments.sublist(5).join('/');
          await _supabase.storage.from(bucket).remove([path]);
        }
      }
    } catch (e) {
      logger.e('Error removing image: $e');
    }
  }

  // ====== PROVEEDORES ========================================================

  Stream<List<Map<String, dynamic>>> getProvidersRealTimeStream() {
    return _supabase.from('providers').stream(primaryKey: [
      'id'
    ]) // Assuming 'id' is PK, which is 'userId' usually
        .eq('isActive', true);
  }

  Future<void> updateProvider(
      String providerId, Map<String, dynamic> data) async {
    // 'providers' table uses providerId (userId) as PK?
    // In Firestore it was .doc(providerId).
    // In Supabase we assume 'id' column matches providerId.
    // However, user might be using 'userId' column as PK or separate 'id'.
    // We'll assume table 'providers' has PK 'id' = providerId.
    // If not, we might need .eq('userId', providerId) for update if id is auto-inc.
    // But usually in migration we keep string IDs.

    await updateDocument('providers', providerId, data);
    _triggerProviderChangeEvent('provider_updated', providerId, data: data);
  }

  Future<Map<String, dynamic>?> getProviderProfile(String providerId) {
    return getDocument('providers', providerId);
  }

  Future<Map<String, dynamic>?> getProviderById(String providerId) {
    return getDocument('providers', providerId);
  }

  Stream<List<Map<String, dynamic>>> getVerifiedProviders() {
    return _supabase
        .from('providers')
        .stream(primaryKey: ['id'])
        .order('rating', ascending: false)
        .map((list) => list
            .where((p) => p['isVerified'] == true && p['isActive'] == true)
            .toList());
  }

  // ====== BOOKINGS ===========================================================

  Stream<List<Map<String, dynamic>>> getActiveUserBookings(String userId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('date', ascending: true)
        .map((list) => list
            .where((b) =>
                b['client_id'] == userId &&
                ['pending', 'confirmed', 'in_progress'].contains(b['status']))
            .take(5)
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getAllUserBookings(String userId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.where((b) => b['client_id'] == userId).toList());
  }

  Stream<List<Map<String, dynamic>>> getClientBookings(String userId) {
    return getAllUserBookings(userId);
  }

  Stream<List<Map<String, dynamic>>> getClientBookingsByStatus(
      String userId, String status) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list
            .where((b) => b['client_id'] == userId && b['status'] == status)
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getProviderBookings(
      String providerId, String status) {
    return _supabase.from('bookings').stream(primaryKey: ['id']).map((list) =>
        list
            .where(
                (b) => b['provider_id'] == providerId && b['status'] == status)
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getProviderBookingsByStatus(
      String providerId, String status) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list
            .where(
                (b) => b['provider_id'] == providerId && b['status'] == status)
            .toList());
  }

  Future<String> createClientBooking({
    required String clientId,
    required String providerId,
    required String serviceId,
    required String serviceTitle,
    required String providerName,
    required double totalPrice,
    required DateTime scheduledDate,
    required String address,
    int estimatedHours = 1,
    String? notes,
  }) async {
    final data = {
      'client_id': clientId,
      'provider_id': providerId,
      'service_id': serviceId,
      'service_title': serviceTitle,
      'provider_name': providerName,
      'total_price': totalPrice,
      'date': scheduledDate.toIso8601String(),
      'address': address,
      'estimated_hours': estimatedHours,
      'notes': notes,
      'status': 'pending',
      'has_rated': false,
    };
    final id = await createDocument('bookings', data);
    await _notifyNewBooking(id, data);
    return id;
  }

  Future<String> createBooking(Map<String, dynamic> data) async {
    return createDocument('bookings', data);
  }

  Future<Map<String, dynamic>?> getBooking(String bookingId) {
    return getDocument('bookings', bookingId);
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    final update = <String, dynamic>{
      'status': newStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    switch (newStatus) {
      case 'accepted':
        update['accepted_at'] = DateTime.now().toIso8601String();
        break;
      case 'in_progress':
        update['started_at'] = DateTime.now().toIso8601String();
        break;
      case 'completed':
        update['completed_at'] = DateTime.now().toIso8601String();
        break;
      case 'rejected':
        update['rejected_at'] = DateTime.now().toIso8601String();
        break;
      case 'cancelled':
        update['cancelled_at'] = DateTime.now().toIso8601String();
        break;
      case 'paid':
        update['paid_at'] = DateTime.now().toIso8601String();
        break;
    }
    await updateDocument('bookings', bookingId, update);
    await _notifyBookingStatusUpdate(bookingId, newStatus);
  }

  Future<void> cancelBooking(String bookingId) async {
    await updateDocument('bookings', bookingId, {
      'status': 'cancelled',
      'cancelled_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteBooking(String bookingId) async {
    await deleteDocument('bookings', bookingId);
  }

  Future<void> rateService({
    required String bookingId,
    required String serviceId,
    required String providerId,
    required double rating,
    String? review,
  }) async {
    await updateDocument('bookings', bookingId, {
      'has_rated': true,
      'rating': rating,
      'review': review,
      'rated_at': DateTime.now().toIso8601String(),
    });
    await _updateServiceRating(serviceId, rating);
    await _updateProviderRating(providerId, rating);
  }

  Future<void> _updateServiceRating(String serviceId, double newRating) async {
    final s = await getDocument('services', serviceId);
    if (s != null) {
      final current = (s['rating'] as num? ?? 0.0).toDouble();
      final total = (s['totalRatings'] as num? ?? 0).toInt();
      final newTotal = total + 1;
      final updated = ((current * total) + newRating) / newTotal;
      await updateDocument('services', serviceId, {
        'rating': updated,
        'totalRatings': newTotal,
      });
    }
  }

  Future<void> _updateProviderRating(
      String providerId, double newRating) async {
    final p = await getDocument('providers', providerId);
    if (p != null) {
      final current = (p['rating'] as num? ?? 0.0).toDouble();
      final total = (p['totalRatings'] as num? ?? 0).toInt();
      final newTotal = total + 1;
      final updated = ((current * total) + newRating) / newTotal;
      await updateDocument('providers', providerId, {
        'rating': updated,
        'totalRatings': newTotal,
      });
    }
  }

  // ====== NOTIFICACIONES =====================================================
  // Supabase doesn't have "Cloud Messaging" built-in like Firebase.
  // We will store notifications in a table 'notifications' and stream them.
  // Push notifications need an external service (OneSignal/FCM) triggered by Edge Functions/Webhooks.
  // For now we assume in-app notifications via the table.

  Future<void> _createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await createDocument('notifications', {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data ?? {},
      'read': false,
    });
  }

  Future<void> _notifyNewBooking(
      String bookingId, Map<String, dynamic> booking) async {
    final providerId = booking['providerId'] as String;
    // Fetch booking if needed? No 'booking' map has data.
    await _createNotification(
      userId: providerId,
      title: 'Nueva reserva',
      message:
          '${booking['clientName'] ?? 'Cliente'} ha solicitado tu servicio.',
      type: 'new_booking',
      data: {'bookingId': bookingId},
    );
  }

  Future<void> _notifyBookingStatusUpdate(
      String bookingId, String status) async {
    final b = await getBooking(bookingId);
    if (b == null) return;
    final clientId = b['clientId'];
    if (clientId != null) {
      await _createNotification(
        userId: clientId,
        title: 'Reserva actualizada',
        message: 'Tu reserva esta ahora: $status',
        type: 'booking_update',
        data: {'bookingId': bookingId, 'status': status},
      );
    }
  }

  // ====== SOLICITUDES PROVEEDOR =============================================

  Future<String> createProviderRequest(Map<String, dynamic> requestData) async {
    requestData['status'] = 'pending';
    return createDocument('provider_requests', requestData);
  }

  Stream<List<Map<String, dynamic>>> getProviderRequests({String? status}) {
    var q = _supabase
        .from('provider_requests')
        .stream(primaryKey: ['id']).order('createdAt', ascending: false);
    if (status != null) {
      return q.map((list) => list.where((l) => l['status'] == status).toList());
    }
    return q;
  }

  // ====== CHAT (Legacy Proxy to ChatProvider/Supabase directly) =============
  // Assuming ChatProvider handles most logic now.
  // Keeping method for compatibility if some screens call it.

  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('last_message_time', ascending: false)
        .map((list) => list.where((c) {
              final parts = List<String>.from(c['participants'] ?? []);
              return parts.contains(userId);
            }).toList());
  }

  // ====== ESTADISTICAS ======================================================

  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    // Count queries are expensive in NoSQL/Supabase if not using count() estimate.
    // Supabase .count()
    final all = await _supabase
        .from('bookings')
        .count(CountOption.exact)
        .eq('client_id', userId);
    final completed = await _supabase
        .from('bookings')
        .count(CountOption.exact)
        .eq('client_id', userId)
        .eq('status', 'completed');
    final pending = await _supabase
        .from('bookings')
        .count(CountOption.exact)
        .eq('client_id', userId)
        .eq('status', 'pending');

    // Sum total spent? Postgres function needed or client side sum (expensive).
    // Client side sum for now (limit logic or sum):
    // If user has thousands, this is bad.
    // Optimization: use rpc or just fetch simple sum.
    // For migration simplicity:
    final bookings = await _supabase
        .from('bookings')
        .select('total_price')
        .eq('client_id', userId)
        .eq('status', 'completed');
    double spent = 0;
    for (var b in bookings) {
      spent += (b['total_price'] as num? ?? 0).toDouble();
    }

    return {
      'totalBookings': all,
      'completedBookings': completed,
      'pendingBookings': pending,
      'totalSpent': spent,
    };
  }

  // ====== MULTISERVICIO / EXTRAS ============================================

  Future<String> createMultiServiceBooking({
    required String clientId,
    required String providerId,
    required double totalPrice,
    required double finalTotal,
    required List<Map<String, dynamic>> selectedOptions,
    required Map<String, dynamic> serviceData,
    // ... params
  }) async {
    // Simplified signature matching
    final data = {
      'clientId': clientId,
      'providerId': providerId,
      'serviceId': serviceData['serviceId'],
      'totalPrice': totalPrice,
      'finalTotal': finalTotal,
      'selectedOptions': selectedOptions,
      // ... others
      'status': 'pending_confirmation',
    };
    return createDocument('bookings', data);
  }

  // ====== PAYMENTS ==========================================================

  Stream<List<Map<String, dynamic>>> getPaymentHistory(String userId) {
    return _supabase
        .from('payments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.where((p) => p['client_id'] == userId).toList());
  }

  Stream<List<Map<String, dynamic>>> getMonthlyPayments(String userId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _supabase
        .from('payments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.where((p) {
              final date =
                  DateTime.tryParse(p['created_at'].toString()) ?? DateTime(0);
              return p['client_id'] == userId &&
                  date.isAfter(
                      startOfMonth.subtract(const Duration(seconds: 1))) &&
                  date.isBefore(endOfMonth.add(const Duration(days: 1)));
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> getRecentPayments(String userId,
      {int limit = 10}) {
    return _supabase
        .from('payments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(limit)
        .map((list) => list.where((p) => p['client_id'] == userId).toList());
  }

  Future<String> createPayment(Map<String, dynamic> data) async {
    return createDocument('payments', data);
  }

  // ====== PAYMENT METHODS ==================================================

  Stream<List<Map<String, dynamic>>> getUserPaymentMethods(String userId) {
    return _supabase
        .from('payment_methods')
        .stream(primaryKey: ['id'])
        .order('isDefault', ascending: false) // Default first
        .map((list) => list
            .where((p) => p['userId'] == userId && p['isActive'] == true)
            .toList());
  }

  Future<String> addPaymentMethod(
      String userId, Map<String, dynamic> data) async {
    final methodData = {
      ...data,
      'userId': userId,
    };
    // If setting as default, unset others?
    if (data['isDefault'] == true) {
      await _unsetOtherDefaultPaymentMethods(userId);
    }
    return createDocument('payment_methods', methodData);
  }

  Future<void> setDefaultPaymentMethod(String userId, String methodId) async {
    await _unsetOtherDefaultPaymentMethods(userId);
    await updateDocument('payment_methods', methodId, {'isDefault': true});
  }

  Future<void> _unsetOtherDefaultPaymentMethods(String userId) async {
    // This needs to be a real query update, but Supabase stream/client restrictions...
    // We will fetch all defaults and false them.
    // In SQL: UPDATE payment_methods SET isDefault = false WHERE userId = uid
    await _supabase
        .from('payment_methods')
        .update({'isDefault': false}).eq('userId', userId);
  }

  Future<void> deletePaymentMethod(String userId, String methodId) async {
    await updateDocument('payment_methods', methodId, {'isActive': false});
  }

  // Fallback methods to prevent crashes for not-yet-implemented minor features
  // Implement as needed.

  Future<List<Map<String, dynamic>>> searchProviders(String term) async {
    final res = await _supabase.from('providers').select().eq('isActive', true);
    final s = term.toLowerCase();
    return res
        .where((p) => (p['name'] as String? ?? '').toLowerCase().contains(s))
        .map((e) => e)
        .toList();
  }

  Stream<List<Map<String, dynamic>>> getClientRecentBookings(String userId,
      {int limit = 5}) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(limit)
        .map((list) => list.where((b) => b['client_id'] == userId).toList());
  }

  Future<void> reportProblem({
    required String bookingId,
    required String providerId,
    required String userId,
    required String reason,
    required String description,
  }) async {
    await createDocument('reports', {
      'bookingId': bookingId,
      'providerId': providerId,
      'userId': userId,
      'reason': reason,
      'description': description,
      'status': 'open',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProviderRequestStatus(
      String requestId, String status) async {
    await updateDocument('provider_requests', requestId, {'status': status});
  }

  Future<Map<String, dynamic>?> getServiceById(String serviceId) async {
    return getDocument('services', serviceId);
  }

  Future<Map<String, dynamic>> getClientBookingStats(String userId) async {
    final all = await _supabase
        .from('bookings')
        .count(CountOption.exact)
        .eq('clientId', userId);
    final completed = await _supabase
        .from('bookings')
        .count(CountOption.exact)
        .eq('client_id', userId)
        .eq('status', 'completed');
    final cancelled = await _supabase
        .from('bookings')
        .count(CountOption.exact)
        .eq('client_id', userId)
        .eq('status', 'cancelled');

    return {
      'total': all,
      'completed': completed,
      'cancelled': cancelled,
    };
  }
}
