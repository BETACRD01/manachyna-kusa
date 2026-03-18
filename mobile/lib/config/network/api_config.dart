/// Clase de configuración centralizada para la API.
/// 
/// Maneja la conmutación entre entornos de desarrollo (túneles) y producción
/// de forma segura utilizando variables de compilación.
abstract class ApiConfig {
  // Constructor privado para evitar instanciación.
  ApiConfig._();

  // ============================================================================
  // CONFIGURACIÓN DE ENTORNOS
  // ============================================================================

  /// URL de desarrollo inyectada en tiempo de ejecución (ej: Túnel Cloudflare).
  /// Se recomienda pasarla vía --dart-define=DEV_API_URL=https://...
  static const String _devUrl = String.fromEnvironment('DEV_API_URL');

  /// URL final de producción.
  static const String _prodUrl = 'https://api.jpexpress.com';

  /// Determina si la app está en modo producción.
  /// Se activa pasando --dart-define=IS_PRODUCTION=true al compilar.
  static const bool _isProduction = bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);

  // ============================================================================
  // GETTERS PÚBLICOS
  // ============================================================================

  static bool get isProduction => _isProduction;
  static bool get isDevelopment => !_isProduction;

  /// Retorna la URL base validada según el entorno actual.
  static String get baseUrl {
    final url = _isProduction ? _prodUrl : _devUrl;
    
    // Validación básica de formato.
    if (url.isEmpty || !url.startsWith('http')) {
      throw UnsupportedError('URL de API malformada o vacía: $url');
    }
    
    return url;
  }

  /// Endpoint principal de la API reconciliado con la versión actual (v1).
  static String get apiUrl => '${baseUrl.replaceAll(RegExp(r'/$'), '')}/api/v1';
}
