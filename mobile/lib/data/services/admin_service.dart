// lib/data/services/admin_service.dart
import '../../core/utils/app_logger.dart';
import 'base_api_service.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final BaseApiService _apiService = BaseApiService();

  /// Crea un nuevo administrador en el sistema.
  Future<void> createAdmin({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      AppLogger.i('Creando nuevo administrador en Django: $email');
      
      await _apiService.post('admins/', body: {
        'email': email,
        'password': password,
        'name': name,
        ...?extraData,
      });

      AppLogger.i('Administrador creado exitosamente.');
    } catch (e) {
      AppLogger.e('Error creando administrador en Django: $e');
      rethrow;
    }
  }

  /// Obtiene la lista de todos los administradores.
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final response = await _apiService.get('admins/');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.e('Error obteniendo administradores: $e');
      return [];
    }
  }

  /// Actualiza los permisos de un administrador.
  Future<void> updateAdminPermissions(String adminId, Map<String, bool> permissions) async {
    try {
      await _apiService.post('admins/$adminId/update-permissions/', body: {
        'permissions': permissions,
      });
      AppLogger.i('Permisos actualizados para admin: $adminId');
    } catch (e) {
      AppLogger.e('Error actualizando permisos: $e');
      rethrow;
    }
  }

  /// Activa o desactiva a un administrador.
  Future<void> toggleAdminStatus(String adminId, bool isActive) async {
    try {
      await _apiService.post('admins/$adminId/toggle-status/', body: {
        'is_active': isActive,
      });
      AppLogger.i('Estado actualizado para admin: $adminId');
    } catch (e) {
      AppLogger.e('Error cambiando estado del admin: $e');
      rethrow;
    }
  }
}
