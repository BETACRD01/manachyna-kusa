// lib/data/services/notification_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    // Nota: Firebase Messaging (FCM) fue removido.
    // Si se requiere Push Notifications, integrar OneSignal o configurar Supabase Edge Functions con FCM HTTP v1.
  }

  // Configurar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Manejar tap en notificación local
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificación local tocada: ${response.payload}');
    // Procesar payload y navegar
  }

  // Crear notificación en Supabase
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    NotificationPriority priority = NotificationPriority.normal,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      final notificationData = {
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
        'created_at': DateTime.now().toIso8601String(),
        'priority': priority.name,
        'is_read': false,
        'image_url': imageUrl,
        'action_url': actionUrl,
      };

      await _supabase.from('notifications').insert(notificationData);

      // Desencadenar notificación local si el usuario está activo (opcional)
      // O confiar en Realtime subscription en UI.

      debugPrint('Notificación creada: $title');
    } catch (e) {
      debugPrint('Error creando notificación: $e');
    }
  }

  // Obtener notificaciones del usuario
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .map((list) => list
            .where((n) => n['user_id'] == userId)
            .map((doc) => NotificationModel.fromJson(doc))
            .toList());
  }

  // Marcar notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marcando notificación como leída: $e');
    }
  }

  // Obtener count de notificaciones no leídas
  Stream<int> getUnreadCount(String userId) {
    return _supabase.from('notifications').stream(primaryKey: ['id']).map(
        (list) => list
            .where((n) => n['user_id'] == userId && n['is_read'] == false)
            .length);
  }

  // Limpiar notificaciones antiguas
  Future<void> clearOldNotifications(String userId) async {
    try {
      final cutoffDate =
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .lt('created_at', cutoffDate);

      debugPrint('Notificaciones antiguas eliminadas');
    } catch (e) {
      debugPrint('Error limpiando notificaciones: $e');
    }
  }

  // Crear notificaciones específicas para Tena
  Future<void> createBookingNotification(
      String userId, String bookingId, String status) async {
    String title, body;

    switch (status) {
      case 'confirmed':
        title = 'Reserva Confirmada';
        body =
            'Tu solicitud de servicio ha sido confirmada. El proveedor se pondrá en contacto contigo.';
        break;
      case 'started':
        title = 'Servicio Iniciado';
        body = 'El proveedor ha llegado y comenzó tu servicio de limpieza.';
        break;
      case 'completed':
        title = 'Servicio Completado';
        body =
            'Tu servicio ha sido completado. ¡No olvides calificar al proveedor!';
        break;
      case 'cancelled':
        title = 'Reserva Cancelada';
        body =
            'Tu reserva ha sido cancelada. Te reembolsaremos el anticipo en 24-48 horas.';
        break;
      default:
        title = 'Actualización de Reserva';
        body = 'Hay una actualización en tu reserva de servicio.';
    }

    await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.booking.toString().split('.').last, // 'booking'
      data: {
        'booking_id': bookingId,
        'status': status,
        'type': 'booking_update',
      },
      priority: NotificationPriority.high,
    );
  }

  Future<void> createPaymentNotification(
      String userId, double amount, String status) async {
    String title, body;

    switch (status) {
      case 'received':
        title = 'Pago Recibido';
        body =
            'Hemos recibido tu pago de \$${amount.toStringAsFixed(2)}. ¡Gracias!';
        break;
      case 'refunded':
        title = 'Reembolso Procesado';
        body =
            'Tu reembolso de \$${amount.toStringAsFixed(2)} ha sido procesado.';
        break;
      default:
        title = 'Actualización de Pago';
        body =
            'Hay una actualización en tu pago de \$${amount.toStringAsFixed(2)}.';
    }

    await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.payment.toString().split('.').last, // 'payment'
      data: {
        'amount': amount,
        'status': status,
        'type': 'payment_update',
      },
    );
  }

  Future<void> createTenaPromotion(
      String userId, String promoTitle, String promoDescription) async {
    await createNotification(
      userId: userId,
      title: 'Promoción',
      body: promoDescription,
      type:
          NotificationType.promotion.toString().split('.').last, // 'promotion'
      data: {
        'type': 'promotion',
        'location': 'Tena',
      },
      priority: NotificationPriority.normal,
    );
  }
}
