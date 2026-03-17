import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:logger/logger.dart';

final logger = Logger();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Logica personalizada para mensajes en segundo plano si es necesario
  logger.d("Mensaje recibido en segundo plano: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ============================================================================
    // INICIALIZACIÓN DE SERVICIOS DE BACKEND
    // ============================================================================

    // Inicializar Firebase (Servicios Híbridos: Auth + Notificaciones)
    logger.i('Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService.initialize();
    logger.i('Firebase inicializado correctamente');

    // NUEVO: Inicializar Supabase (PostgreSQL + Auth + Storage + Realtime)
    logger.i('Inicializando Supabase...');
    await SupabaseConfig.initialize();
    logger.i('Supabase inicializado correctamente');

    // ============================================================================
    // SERVICIOS AUXILIARES
    // ============================================================================

    // Limpiar cache expirado al inicio
    await ImageCacheService.cleanExpiredCache();
    logger.d('Cache de imágenes limpiado');
  } catch (e, stackTrace) {
    logger.e('Error inicializando servicios: $e');
    logger.e('Stack trace: $stackTrace');

    // Mostrar error en pantalla si falla la inicialización
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Error de Inicialización',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    return;
  }

  runApp(const MyApp());
}
