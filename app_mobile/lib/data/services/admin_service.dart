import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createAdmin({
    required String email,
    required String password,
    required Map<String, dynamic> adminData,
  }) async {
    try {
      logger.d('CREANDO NUEVO ADMINISTRADOR');
      logger.d('Email: $email');

      // Crear el nuevo usuario
      // Nota: Supabase signUp iniciará sesión automáticamente si no se deshabilita la confirmación de email,
      // o retornaria sesión nula si requiere confirmación.
      // Advertencia: Esto puede cambiar la sesión actual.
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': adminData['name']},
      );

      final user = response.user;

      if (user != null) {
        // Agregar datos adicionales al adminData
        adminData['id'] = user.id; // Supabase usa 'id' en lugar de 'uid'
        adminData['email'] = email;
        adminData['role'] = 'admin';
        adminData['is_active'] = true;
        adminData['metadata'] = {
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'version': 1,
          'status': 'active',
        };

        // Crear documento en la tabla admins
        await _supabase.from('admins').insert(adminData);

        logger.d('Administrador creado en Supabase');
        logger.d('ADMINISTRADOR CREADO EXITOSAMENTE');
      }
    } catch (e) {
      logger.e('Error creando administrador: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final data = await _supabase.from('admins').select();
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      logger.e('Error obteniendo administradores: $e');
      return [];
    }
  }

  Future<void> updateAdminPermissions(
      String adminId, Map<String, bool> permissions) async {
    try {
      await _supabase.from('admins').update({
        'permissions': permissions,
        'metadata': {
          'updated_at': DateTime.now().toIso8601String()
        }, // JSONB update if metadata is JSON
      }).eq('id', adminId);

      logger.d('Permisos actualizados para admin: $adminId');
    } catch (e) {
      logger.e('Error actualizando permisos: $e');
      rethrow;
    }
  }

  Future<void> toggleAdminStatus(String adminId, bool isActive) async {
    try {
      await _supabase.from('admins').update({
        'is_active': isActive,
      }).eq('id', adminId);

      logger.d('Estado actualizado para admin: $adminId');
    } catch (e) {
      logger.e('Error actualizando estado: $e');
      rethrow;
    }
  }
}
