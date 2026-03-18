// lib/data/services/booking_service.dart
import '../../core/utils/app_logger.dart';
import 'base_api_service.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Crea una reserva desde un pago exitoso.
  /// Se comunica directamente con el backend de Django.
  Future<Map<String, dynamic>> createBookingFromPayment({
    required Map<String, dynamic> checkerBookData,
    required String paymentId,
    String? userId,
  }) async {
    try {
      AppLogger.i('Creando reserva en Django desde pago...');

      final response = await _apiService.post('bookings/', body: {
        'payment_id': paymentId,
        'client_id': userId,
        'client_name': checkerBookData['clientName'],
        'client_phone': checkerBookData['clientPhone'],
        'client_email': checkerBookData['clientEmail'],
        'address': checkerBookData['address'],
        'sector': checkerBookData['selectedSector'],
        'services': checkerBookData['services'],
        'urgency_level': checkerBookData['urgencyLevel'],
        'total_price': checkerBookData['total'],
      });

      return {
        'success': true,
        'bookingId': response['id'].toString(),
        'message': 'Reserva creada exitosamente en el servidor.',
      };
    } catch (e) {
      AppLogger.e('Error creando reserva en Django: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'No se pudo registrar la reserva en el servidor.',
      };
    }
  }

  /// Obtiene las reservas del usuario actual.
  Future<List<Map<String, dynamic>>> getMyBookings() async {
    try {
      final response = await _apiService.get('bookings/me/');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.e('Error obteniendo mis reservas: $e');
      return [];
    }
  }

  /// Asigna un proveedor a una reserva (solo Staff/Admin).
  Future<Map<String, dynamic>> assignProviderToBooking({
    required String bookingId,
    required String providerId,
  }) async {
    try {
      final response = await _apiService.post('bookings/$bookingId/assign/', body: {
        'provider_id': providerId,
      });
      return {
        'success': true,
        'message': 'Proveedor asignado correctamente.',
        'data': response,
      };
    } catch (e) {
      AppLogger.e('Error asignando proveedor: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Vincula reservas temporales creadas antes del login/registro.
  Future<void> linkTemporaryBookings() async {
    try {
      await _apiService.post('bookings/sync-temp/', body: {});
      AppLogger.i('Reservas temporales sincronizadas.');
    } catch (e) {
      AppLogger.w('Fallo al sincronizar reservas temporales: $e');
    }
  }
}
