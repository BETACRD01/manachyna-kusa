import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/image_cache_service.dart';
import '../services/notification_service.dart';
import '../utils/app_logger.dart';
import '../../firebase_options.dart';

/// Encapsulates the application initialization logic with retry mechanisms and error handling.
class AppInitializer {
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 15);

  /// Orchestrates the initialization of all backend services.
  /// Returns normally on success, throws an exception on failure.
  static Future<void> initialize() async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        attempts++;
        AppLogger.i('Iniciando intento de inicialización $attempts/$_maxRetries...');

        await _performInitialization().timeout(
          _timeout,
          onTimeout: () => throw TimeoutException('La inicialización de servicios excedió el tiempo límite.'),
        );

        AppLogger.i('Inicialización completada con éxito.');
        return;
      } catch (e, stackTrace) {
        AppLogger.e('Fallo en intento $attempts de inicialización', e, stackTrace);
        
        if (attempts >= _maxRetries) {
          rethrow;
        }

        // Exponential backoff or simple delay before retry
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }

  /// Internal logic for service initialization.
  static Future<void> _performInitialization() async {
    // 1. Firebase (Critical)
    await _ensureFirebaseInitialized();
    
    // 2. Notifications (Depends on Firebase)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.initialize();
    AppLogger.i('Notificaciones configuradas.');

    // 3. Auxiliary Services (Non-blocking)
    _startAuxiliaryServices();
  }

  /// Guard to prevent multiple Firebase initializations.
  static Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isEmpty) {
      AppLogger.i('Inicializando Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  /// Starts non-critical services without blocking the main startup flow.
  static void _startAuxiliaryServices() {
    // Cache cleanup should not block the app start
    unawaited(ImageCacheService.cleanExpiredCache().catchError((e) {
      AppLogger.e('Error en limpieza de caché en segundo plano', e);
    }));
  }

  /// Global background message handler for FCM.
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Use the same guard as the main initialization
    await _ensureFirebaseInitialized();
    // Avoid logging sensitive IDs in production if not necessary, or use d level cautiously
    AppLogger.d("FCM Background: Notificación recibida.");
  }
}
