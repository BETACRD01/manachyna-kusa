import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import '../../config/supabase_config.dart'; // Importar configuración de Supabase

final logger = Logger();

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

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
      logger.i('Usuario concedió permisos de notificación');
    } else {
      logger.w('Usuario denegó permisos de notificación');
    }

    // Manejar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i(
          'Mensaje recibido en primer plano: ${message.notification?.title}');
    });

    // Manejar cuando la app se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.i('App abierta desde notificación: ${message.messageId}');
    });

    // Escuchar cambios en el token
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      saveTokenToDatabase(newToken);
    });
  }

  /// Guarda el token FCM en la base de datos de Supabase para el usuario actual
  static Future<void> saveTokenToDatabase(String token) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      logger.d('Guardando FCM Token para usuario ${user.id}...');

      // Usamos 'upsert' para mayor resiliencia. Si el registro no existe, lo crea.
      // Si existe, solo actualiza fcm_token y updated_at.
      await supabase.from('users').upsert({
        'uid': user.id,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'uid');

      logger.i('FCM Token guardado exitosamente');
    } catch (e) {
      logger.e('Error guardando FCM Token: $e');
    }
  }

  /// Método público para forzar la actualización del token (ej: al hacer login)
  static Future<void> updateTokenForCurrentUser() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await saveTokenToDatabase(token);
    }
  }
}
