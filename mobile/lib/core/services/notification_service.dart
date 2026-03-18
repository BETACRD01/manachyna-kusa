import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_logger.dart';
import '../../data/services/base_api_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final BaseApiService _apiService = BaseApiService();

  static Future<void> initialize() async {
    // Solicitar permisos para notificaciones
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.i('Usuario concedió permisos de notificación');
    } else {
      AppLogger.w('Usuario denegó permisos de notificación');
    }

    // Manejar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.i('Mensaje recibido en primer plano: ${message.notification?.title}');
    });

    // Manejar cuando la app se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.i('App abierta desde notificación: ${message.messageId}');
    });

    // Escuchar cambios en el token
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      saveTokenToBackend(newToken);
    });
  }

  /// Guarda el token FCM en el backend de Django para el usuario actual
  static Future<void> saveTokenToBackend(String token) async {
    try {
      AppLogger.d('Sincronizando FCM Token con el backend...');
      
      await _apiService.put('users/fcm-token/', body: {
        'fcm_token': token,
      });

      AppLogger.i('FCM Token sincronizado exitosamente con Django');
    } catch (e) {
      AppLogger.e('Error sincronizando FCM Token: $e');
    }
  }

  /// Método público para forzar la actualización del token (ej: al hacer login)
  static Future<void> updateTokenForCurrentUser() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await saveTokenToBackend(token);
    }
  }
}
