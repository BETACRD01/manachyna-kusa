// lib/data/services/payment_service.dart
import '../../core/utils/app_logger.dart';
import 'base_api_service.dart';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled
}

extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending: return 'pending';
      case PaymentStatus.processing: return 'processing';
      case PaymentStatus.completed: return 'completed';
      case PaymentStatus.failed: return 'failed';
      case PaymentStatus.refunded: return 'refunded';
      case PaymentStatus.cancelled: return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending: return 'Pendiente';
      case PaymentStatus.processing: return 'Procesando';
      case PaymentStatus.completed: return 'Completado';
      case PaymentStatus.failed: return 'Fallido';
      case PaymentStatus.refunded: return 'Reembolsado';
      case PaymentStatus.cancelled: return 'Cancelado';
    }
  }
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Procesar pago en efectivo.
  Future<Map<String, dynamic>> processCashPayment({
    required String bookingId,
    required double amount,
    required String serviceTitle,
    required String clientId,
    required String providerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post('payments/', body: {
        'booking_id': bookingId,
        'client_id': clientId,
        'provider_id': providerId,
        'amount': amount,
        'service_title': serviceTitle,
        'payment_method': 'cash',
        'status': PaymentStatus.pending.value,
        'metadata': metadata ?? {},
      });

      return {
        'success': true,
        'paymentId': response['id'].toString(),
        'status': PaymentStatus.pending.value,
        'message': 'Pago en efectivo programado exitosamente',
      };
    } catch (e) {
      AppLogger.e('Error procesando pago en efectivo en Django: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Procesar transferencia bancaria.
  Future<Map<String, dynamic>> processBankTransfer({
    required String bookingId,
    required double amount,
    required String serviceTitle,
    required String clientId,
    required String providerId,
    required String bankName,
    required String accountNumber,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post('payments/', body: {
        'booking_id': bookingId,
        'client_id': clientId,
        'provider_id': providerId,
        'amount': amount,
        'service_title': serviceTitle,
        'payment_method': 'bank_transfer',
        'bank_details': {
          'bank_name': bankName,
          'account_number': accountNumber,
        },
        'status': PaymentStatus.pending.value,
        'metadata': metadata ?? {},
      });

      return {
        'success': true,
        'paymentId': response['id'].toString(),
        'status': PaymentStatus.pending.value,
        'message': 'Transferencia bancaria iniciada',
      };
    } catch (e) {
      AppLogger.e('Error procesando transferencia en Django: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Obtener mis pagos.
  Future<List<Map<String, dynamic>>> getMyPayments() async {
    try {
      final response = await _apiService.get('payments/me/');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.e('Error obteniendo mis pagos desde Django: $e');
      return [];
    }
  }

  /// Confirmar un pago (Staff/Admin).
  Future<Map<String, dynamic>> confirmPayment(String paymentId, {String? transactionId}) async {
    try {
      final response = await _apiService.post('payments/$paymentId/confirm/', body: {
        'transaction_id': transactionId,
      });
      return {
        'success': true,
        'message': 'Pago confirmado correctamente.',
        'data': response,
      };
    } catch (e) {
      AppLogger.e('Error confirmando pago en Django: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
