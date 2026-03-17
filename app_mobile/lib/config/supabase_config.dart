// ============================================================================
// CONFIGURACIÓN DE SUPABASE PARA MANACHYNA KUSA 2.0
// ============================================================================
// Este archivo configura la conexión con Supabase (PostgreSQL + Auth + Storage)
// Reemplaza gradualmente los servicios de Firebase
// ============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class SupabaseConfig {
  // ========================================================================
  // CREDENCIALES DE SUPABASE
  // IMPORTANTE: Reemplaza estos valores con tus credenciales reales
  // Obtén estos valores en: Supabase Dashboard → Settings → API
  // ========================================================================

  // URL del proyecto Supabase
  // Ejemplo: https://tuproyecto.supabase.co
  static const String supabaseUrl = 'https://phlkzrmjvkwzwcmgvrkk.supabase.co';

  // Anon (public) key - Seguro para usar en el cliente
  // Ejemplo: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBobGt6cm1qdmt3endjbWd2cmtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyMzUwODMsImV4cCI6MjA4MzgxMTA4M30.Grvks3AvzuyTqXjAfsti1vDFjlkySpRfCxZxDJ6zehM';

  // ========================================================================
  // CONFIGURACIÓN AVANZADA (OPCIONAL)
  // ========================================================================

  static const Map<String, String> headers = {
    'X-Client-Info': 'manachynakusa-flutter',
  };

  // Configuración de realtime
  static const RealtimeClientOptions realtimeClientOptions =
      RealtimeClientOptions(
    logLevel: RealtimeLogLevel.info,
  );

  // ========================================================================
  // INICIALIZACIÓN
  // ========================================================================

  /// Inicializa Supabase
  /// Debe llamarse en main() antes de runApp()
  static Future<void> initialize() async {
    try {
      _logger.i('Inicializando Supabase...');

      // Validar que las credenciales no sean las de ejemplo
      if (supabaseUrl == 'TU_SUPABASE_URL_AQUI' ||
          supabaseAnonKey == 'TU_ANON_KEY_AQUI') {
        throw Exception(
            'ERROR: Debes configurar las credenciales de Supabase en supabase_config.dart\n'
            'Ve a: Supabase Dashboard → Settings → API para obtenerlas');
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true, // Cambia a false en producción
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: realtimeClientOptions,
        storageOptions: const StorageClientOptions(
          retryAttempts: 3,
        ),
        postgrestOptions: const PostgrestClientOptions(
          schema: 'public',
        ),
      );

      _logger.i('Supabase inicializado correctamente');
      _logger.d('URL: $supabaseUrl');

      // Verificar conexión
      final session = supabase.auth.currentSession;
      if (session != null) {
        _logger.i('Sesión activa detectada: ${session.user.email}');
      } else {
        _logger.d('Sin sesión activa');
      }
    } catch (e, stackTrace) {
      _logger.e('Error inicializando Supabase: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Verifica la conexión con Supabase
  /// Verifica la conexión con Supabase
  static Future<bool> checkConnection() async {
    try {
      // Verificamos que las credenciales estáticas estén configuradas
      // Accedemos a las variables estáticas de la clase, no del cliente
      if (supabaseUrl.isEmpty ||
          supabaseUrl.contains('TU_SUPABASE') ||
          supabaseAnonKey.isEmpty) {
        return false;
      }

      // Verificamos que el cliente esté inicializado
      final client = Supabase.instance.client;

      // Intentamos obtener la sesión actual (no hace llamada de red, pero valida estado)
      final session = client.auth.currentSession;
      _logger.d(
          'Check Connection: Session status ${session != null ? "Active" : "None"}');

      return true;
    } catch (e) {
      _logger.e('Error verificando conexión: $e');
      return false;
    }
  }
}

// ============================================================================
// CLIENTE GLOBAL DE SUPABASE
// ============================================================================

/// Acceso rápido al cliente de Supabase
/// Úsalo en toda la app: `supabase.from('users').select()`
final supabase = Supabase.instance.client;
