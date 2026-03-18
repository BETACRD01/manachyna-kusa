// lib/data/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../../core/utils/app_logger.dart';
import 'base_api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final BaseApiService _apiService = BaseApiService();

  /// Inicializa el servicio de notificaciones.
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  /// Configura el manejo de mensajes de Firebase.
  Future<void> _initializeFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // Solicitar permisos en iOS
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtener y actualizar el token en el backend de Django
    await updateTokenForCurrentUser();

    // Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.d(
          'Mensaje de FCM en primer plano: ${message.notification?.title}');
      _showLocalNotification(message);
    });
  }

  /// Envía el token FCM al backend de Django para vinculación.
  static Future<void> updateTokenForCurrentUser() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final apiService = BaseApiService();
        await apiService
            .post('users/update-fcm-token/', body: {'fcm_token': token});
        AppLogger.i('Token FCM actualizado en Django.');
      }
    } catch (e) {
      AppLogger.e('Error actualizando token FCM en Django: $e');
    }
  }

  /// Configura las notificaciones locales.
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Muestra una notificación local a partir de un mensaje de FCM.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Notificaciones Principales',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data.toString(),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.d('Notificación local tocada: ${response.payload}');
  }

  /// Obtiene el historial de notificaciones desde el backend de Django.
  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final response = await _apiService.get('notifications/');
      return (response as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList();
    } catch (e) {
      AppLogger.e('Error obteniendo notificaciones desde Django: $e');
      return [];
    }
  }

  /// Marca una notificación como leída en el backend.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService
          .post('notifications/$notificationId/mark-read/', body: {});
    } catch (e) {
      AppLogger.e('Error marcando notificación como leída: $e');
    }
  }
}
