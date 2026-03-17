// lib/data/services/payment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

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
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pendiente';
      case PaymentStatus.processing:
        return 'Procesando';
      case PaymentStatus.completed:
        return 'Completado';
      case PaymentStatus.failed:
        return 'Fallido';
      case PaymentStatus.refunded:
        return 'Reembolsado';
      case PaymentStatus.cancelled:
        return 'Cancelado';
    }
  }
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // ========================================
  // MÉTODOS DE PAGO PRINCIPALES
  // ========================================

  /// Procesar pago en efectivo
  Future<Map<String, dynamic>> processCashPayment({
    required String bookingId,
    required double amount,
    required String serviceTitle,
    required String clientId,
    required String providerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final paymentData = {
        'booking_id': bookingId,
        'client_id': clientId,
        'provider_id': providerId,
        'amount': amount,
        'service_title': serviceTitle,
        'payment_method': {
          'type': 'cash',
          'displayName': 'Efectivo al finalizar',
        },
        'status': PaymentStatus.pending.value,
        'currency': 'USD',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
      };

      final response = await _supabase
          .from('payments')
          .insert(paymentData)
          .select()
          .single();

      final paymentId = response['id'].toString();

      logger.d('Pago en efectivo creado: $paymentId');

      return {
        'success': true,
        'paymentId': paymentId,
        'status': PaymentStatus.pending.value,
        'message': 'Pago en efectivo programado exitosamente',
      };
    } catch (e) {
      logger.e('Error procesando pago en efectivo: $e');
      return {
        'success': false,
        'error': 'Error técnico',
        'message': 'No se pudo procesar el pago',
      };
    }
  }

  /// Procesar transferencia bancaria
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
      final paymentData = {
        'booking_id': bookingId,
        'client_id': clientId,
        'provider_id': providerId,
        'amount': amount,
        'service_title': serviceTitle,
        'payment_method': {
          'type': 'bank_transfer',
          'displayName': 'Transferencia bancaria',
          'bankName': bankName,
          'accountNumber': accountNumber,
        },
        'status': PaymentStatus.pending.value,
        'currency': 'USD',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
        'instructions': _getBankTransferInstructions(bankName, accountNumber),
      };

      final response = await _supabase
          .from('payments')
          .insert(paymentData)
          .select()
          .single();

      final paymentId = response['id'].toString();

      // Crear notificación para el cliente con instrucciones
      await _createPaymentNotification(
        clientId,
        'Instrucciones de transferencia',
        'Revisa las instrucciones para completar tu transferencia bancaria',
        paymentId,
      );

      logger.d('Transferencia bancaria creada: $paymentId');

      return {
        'success': true,
        'paymentId': paymentId,
        'status': PaymentStatus.pending.value,
        'message': 'Transferencia bancaria iniciada',
        'instructions': _getBankTransferInstructions(bankName, accountNumber),
      };
    } catch (e) {
      logger.e('Error procesando transferencia: $e');
      return {
        'success': false,
        'error': 'Error técnico',
        'message': 'No se pudo procesar la transferencia',
      };
    }
  }

  /// Obtener instrucciones de transferencia
  Map<String, dynamic> _getBankTransferInstructions(
      String bankName, String accountNumber) {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolder': 'Servicios Tena',
      'accountType': 'Ahorros',
      'instructions': [
        'Realiza la transferencia a la cuenta indicada',
        'Usa como referencia tu número de pedido',
        'Envía el comprobante por WhatsApp',
        'Tu servicio será confirmado al verificar el pago',
      ],
      'supportPhone': '+593 987 654 321',
      'supportWhatsApp': '+593 987 654 321',
    };
  }

  // ========================================
  // GESTIÓN DE ESTADOS DE PAGO
  // ========================================

  /// Actualizar estado del pago
  Future<void> updatePaymentStatus(
    String paymentId,
    PaymentStatus newStatus, {
    String? transactionId,
    String? failureReason,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updateData = {
        'status': newStatus.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Agregar campos específicos según el estado
      switch (newStatus) {
        case PaymentStatus.processing:
          updateData['processing_at'] = DateTime.now().toIso8601String();
          break;
        case PaymentStatus.completed:
          updateData['completed_at'] = DateTime.now().toIso8601String();
          if (transactionId != null) {
            updateData['transaction_id'] = transactionId;
          }
          break;
        case PaymentStatus.failed:
          updateData['failed_at'] = DateTime.now().toIso8601String();
          if (failureReason != null) {
            updateData['failure_reason'] = failureReason;
          }
          break;
        case PaymentStatus.refunded:
          updateData['refunded_at'] = DateTime.now().toIso8601String();
          break;
        case PaymentStatus.cancelled:
          updateData['cancelled_at'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      if (additionalData != null) {
        additionalData.forEach((key, value) {
          updateData[key] = value;
        });
      }

      await _supabase.from('payments').update(updateData).eq('id', paymentId);

      // Notificar cambio de estado
      await _notifyPaymentStatusChange(paymentId, newStatus);

      logger.d('Estado del pago actualizado: $paymentId -> ${newStatus.value}');
    } catch (e) {
      logger.e('Error actualizando estado del pago: $e');
      rethrow;
    }
  }

  /// Confirmar pago manual (para efectivo y transferencias)
  Future<Map<String, dynamic>> confirmPayment(
    String paymentId, {
    String? transactionId,
    String? notes,
  }) async {
    try {
      await updatePaymentStatus(
        paymentId,
        PaymentStatus.completed,
        transactionId: transactionId,
        additionalData: {
          'confirmedBy': _supabase.auth.currentUser?.id,
          'confirmationNotes': notes,
          'confirmationMethod': 'manual',
        },
      );

      return {
        'success': true,
        'message': 'Pago confirmado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error confirmando pago',
        'message': e.toString(),
      };
    }
  }

  // ========================================
  // CONSULTAS DE PAGOS
  // ========================================

  /// Obtener pago por ID
  Future<Map<String, dynamic>?> getPayment(String paymentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('id', paymentId)
          .maybeSingle();
      return response;
    } catch (e) {
      logger.e('Error obteniendo pago: $e');
      return null;
    }
  }

  /// Obtener pagos del usuario
  Stream<List<Map<String, dynamic>>> getUserPayments(String userId) {
    return _supabase
        .from('payments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.where((p) => p['client_id'] == userId).toList());
  }

  /// Obtener pagos del proveedor
  Stream<List<Map<String, dynamic>>> getProviderPayments(String providerId) {
    return _supabase
        .from('payments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) =>
            list.where((p) => p['provider_id'] == providerId).toList());
  }

  /// Obtener pagos por estado
  Stream<List<Map<String, dynamic>>> getPaymentsByStatus(PaymentStatus status) {
    return _supabase
        .from('payments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.where((p) => p['status'] == status.value).toList());
  }

  // ========================================
  // ESTADÍSTICAS DE PAGOS
  // ========================================

  /// Obtener estadísticas de pagos del usuario
  Future<Map<String, dynamic>> getUserPaymentStats(String userId) async {
    try {
      // In Supabase, aggregation is often done via RPC or client side if data is small.
      // Fetching all payments for a user to calculate stats.

      final paymentsQuery =
          await _supabase.from('payments').select().eq('client_id', userId);

      double totalPaid = 0;
      double totalPending = 0;
      int completedCount = 0;
      int pendingCount = 0;
      int failedCount = 0;

      for (var data in paymentsQuery) {
        final amount = (data['amount'] ?? 0).toDouble();
        final status = data['status'] ?? 'pending';

        switch (status) {
          case 'completed':
            totalPaid += amount;
            completedCount++;
            break;
          case 'pending':
            totalPending += amount;
            pendingCount++;
            break;
          case 'failed':
            failedCount++;
            break;
        }
      }

      return {
        'totalPaid': totalPaid,
        'totalPending': totalPending,
        'completedCount': completedCount,
        'pendingCount': pendingCount,
        'failedCount': failedCount,
        'totalTransactions': paymentsQuery.length,
      };
    } catch (e) {
      logger.e('Error obteniendo estadísticas: $e');
      return {
        'totalPaid': 0.0,
        'totalPending': 0.0,
        'completedCount': 0,
        'pendingCount': 0,
        'failedCount': 0,
        'totalTransactions': 0,
      };
    }
  }

  // ========================================
  // NOTIFICACIONES
  // ========================================

  /// Crear notificación de pago
  Future<void> _createPaymentNotification(
    String userId,
    String title,
    String message,
    String paymentId,
  ) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': message,
        'type': 'payment',
        'data': {
          'payment_id': paymentId,
        },
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      logger.e('Error creando notificación: $e');
    }
  }

  /// Notificar cambio de estado de pago
  Future<void> _notifyPaymentStatusChange(
      String paymentId, PaymentStatus newStatus) async {
    try {
      final paymentDoc = await getPayment(paymentId);

      if (paymentDoc == null) return;

      final paymentData = paymentDoc;
      final clientId = paymentData['client_id'];
      final providerId = paymentData['provider_id'];
      final amount = paymentData['amount'];

      String title = '';
      String message = '';

      switch (newStatus) {
        case PaymentStatus.completed:
          title = 'Pago confirmado';
          message =
              'Tu pago de \$${amount.toStringAsFixed(2)} ha sido confirmado';
          break;
        case PaymentStatus.failed:
          title = 'Pago fallido';
          message =
              'Hubo un problema con tu pago de \$${amount.toStringAsFixed(2)}';
          break;
        case PaymentStatus.refunded:
          title = 'Reembolso procesado';
          message =
              'Tu reembolso de \$${amount.toStringAsFixed(2)} ha sido procesado';
          break;
        default:
          return; // No notificar otros estados
      }

      // Notificar al cliente
      await _createPaymentNotification(clientId, title, message, paymentId);

      // Notificar al proveedor si el pago se completó
      if (newStatus == PaymentStatus.completed && providerId != null) {
        await _createPaymentNotification(
          providerId,
          'Pago recibido',
          'Has recibido un pago de \$${amount.toStringAsFixed(2)}',
          paymentId,
        );
      }
    } catch (e) {
      logger.e('Error notificando cambio de estado: $e');
    }
  }

  // ========================================
  // UTILIDADES
  // ========================================

  /// Validar monto de pago
  bool isValidAmount(double amount) {
    return amount > 0 && amount <= 1000; // Límite máximo de $1000
  }

  /// Obtener comisión de la plataforma
  double getPlatformFee(double amount) {
    return amount * 0.05; // 5% de comisión
  }

  /// Calcular monto neto para el proveedor
  double getProviderAmount(double totalAmount) {
    return totalAmount - getPlatformFee(totalAmount);
  }

  /// Generar referencia de pago
  String generatePaymentReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'PAY-$timestamp';
  }
}
