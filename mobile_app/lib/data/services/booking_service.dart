// lib/data/services/booking_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // CREAR RESERVA DESDE PAGO (NUEVA FUNCIÓN)
  Future<Map<String, dynamic>> createBookingFromPayment({
    required Map<String, dynamic> checkerBookData,
    required String paymentId,
    String? userId,
  }) async {
    try {
      logger.i('Creando reserva desde pago...');

      // Preparar datos de la reserva
      final bookingData = {
        'client_id': userId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
        'client_name': checkerBookData['clientName'],
        'client_phone': checkerBookData['clientPhone'],
        'client_email': checkerBookData['clientEmail'] ?? '',
        'address': checkerBookData['address'],
        'selected_sector': checkerBookData['selectedSector'],
        'services': checkerBookData['services'],
        'urgency_level': checkerBookData['urgencyLevel'],
        'total_price': checkerBookData['total'],
        'payment_id': paymentId,
        'status': 'paid', // ESTADO PAGADO AUTOMÁTICAMENTE
        'payment_status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'needs_provider_assignment': true, // Para asignar proveedor después
      };

      // Crear la reserva en Supabase
      final response = await _supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      final bookingId = response['id'].toString();

      logger.i('Reserva creada con ID: $bookingId');

      // NOTIFICAR A PROVEEDORES RELEVANTES
      await _notifyRelevantProviders(bookingId, checkerBookData);

      // CREAR NOTIFICACIÓN PARA EL CLIENTE
      await _createClientNotification(
        checkerBookData['clientName'],
        'Pedido confirmado',
        'Tu pedido ha sido confirmado y será asignado a un proveedor pronto.',
        bookingId,
      );

      return {
        'success': true,
        'bookingId': bookingId,
        'message': 'Reserva creada exitosamente',
      };
    } catch (e) {
      logger.e('Error creando reserva desde pago: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al crear la reserva',
      };
    }
  }

  // NOTIFICAR A PROVEEDORES RELEVANTES
  Future<void> _notifyRelevantProviders(
      String bookingId, Map<String, dynamic> checkerBookData) async {
    try {
      logger.d('Notificando a proveedores relevantes...');

      // Obtener servicios solicitados
      final services = checkerBookData['services'] as List<dynamic>;
      final serviceCategories =
          services.map((s) => s['category'] ?? 'other').toSet();
      final sector = checkerBookData['selectedSector'];

      // Buscar proveedores que ofrezcan estos servicios en este sector
      // Supabase filter for array contains?
      // providers table 'serviceAreas' is array? .contains() operator via .cs() or .filter
      // 'isActive' is bool.
      final providersQuery =
          await _supabase.from('providers').select().eq('isActive', true);
      // Simple client side filter for arrays if needed or use .contains() if supported

      for (var providerDoc in providersQuery) {
        final providerData = providerDoc;
        final serviceAreas =
            List<String>.from(providerData['serviceAreas'] ?? []);

        if (!serviceAreas.contains(sector)) continue;

        final providerServices =
            List<String>.from(providerData['serviceCategories'] ?? []);

        // Verificar si el proveedor ofrece alguno de los servicios solicitados
        final hasMatchingService = serviceCategories
            .any((category) => providerServices.contains(category));

        if (hasMatchingService) {
          // Crear notificación para el proveedor
          await _supabase.from('notifications').insert({
            'user_id': providerData['id'],
            'user_type': 'provider',
            'title': 'Nueva solicitud de servicio',
            'body':
                'Hay una nueva solicitud que coincide con tus servicios en $sector',
            'type': 'new_booking',
            'data': {
              'booking_id': bookingId,
              'client_name': checkerBookData['clientName'],
              'sector': sector,
              'services': services.map((s) => s['serviceTitle']).join(', '),
              'total': checkerBookData['total'],
              'urgency': checkerBookData['urgencyLevel'],
            },
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          });

          logger.i('Notificación enviada a proveedor: ${providerData['id']}');
        }
      }
    } catch (e) {
      logger.e('Error notificando proveedores: $e');
    }
  }

  // CREAR NOTIFICACIÓN PARA EL CLIENTE
  Future<void> _createClientNotification(
    String clientName,
    String title,
    String message,
    String bookingId,
  ) async {
    try {
      await _supabase.from('notifications').insert({
        'client_name': clientName, // Temporal hasta que se registre
        'title': title,
        'body': message,
        'type': 'booking_confirmation',
        'data': {
          'booking_id': bookingId,
        },
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      logger.i('Notificación creada para cliente: $clientName');
    } catch (e) {
      logger.e('Error creando notificación cliente: $e');
    }
  }

  // OBTENER RESERVAS POR ESTADO DE PAGO
  Stream<List<Map<String, dynamic>>> getBookingsByPaymentStatus(String status) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) =>
            list.where((b) => b['payment_status'] == status).toList());
  }

  // ASIGNAR PROVEEDOR A RESERVA
  Future<Map<String, dynamic>> assignProviderToBooking({
    required String bookingId,
    required String providerId,
    required String providerName,
  }) async {
    try {
      await _supabase.from('bookings').update({
        'provider_id': providerId,
        'provider_name': providerName,
        'status': 'assigned',
        'assigned_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'needs_provider_assignment': false,
      }).eq('id', bookingId);

      return {
        'success': true,
        'message': 'Proveedor asignado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // OBTENER RESERVAS PENDIENTES DE ASIGNACIÓN
  Stream<List<Map<String, dynamic>>> getPendingAssignmentBookings() {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list
            .where((b) =>
                b['needs_provider_assignment'] == true &&
                b['payment_status'] == 'completed')
            .toList());
  }

  // VINCULAR RESERVAS TEMPORALES CON USUARIO REGISTRADO
  Future<void> linkTemporaryBookingsToUser(
      String userId, String clientEmail) async {
    try {
      logger.d('Vinculando reservas temporales al usuario: $userId');

      // Buscar reservas temporales por email o nombre
      final tempBookingsQuery = await _supabase
          .from('bookings')
          .select()
          .eq('client_email', clientEmail)
          .gt('client_id', 'temp_');

      // Note: .gt with string comparison might heavily depend on DB collation.
      // But assuming 'temp_' prefix sorts after UUIDs or similar?
      // Actually UUIDs (if used) might sort differently.
      // Better filter in client if needed or strict usage of 'temp_'.

      // Let's iterate and update.
      for (var doc in tempBookingsQuery) {
        if (doc['client_id'].toString().startsWith('temp_')) {
          await _supabase.from('bookings').update({
            'client_id': userId,
            'is_temporary': false,
            'linked_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', doc['id']);

          logger.i('Reserva ${doc['id']} vinculada al usuario $userId');
        }
      }
    } catch (e) {
      logger.e('Error vinculando reservas temporales: $e');
    }
  }
}
