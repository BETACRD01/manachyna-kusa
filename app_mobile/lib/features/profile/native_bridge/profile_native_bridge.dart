// lib/services/profile_native_bridge.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:logger/logger.dart';

final Logger logger = Logger();

/// Bridge para operaciones del perfil con Supabase
class ProfileNativeBridge {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene estadísticas del usuario
  static Future<Map<String, dynamic>?> getUserStats([String? userId]) async {
    try {
      final String uid = userId ?? _supabase.auth.currentUser?.id ?? '';
      if (uid.isEmpty) return null;

      // Obtener datos del usuario
      final userData =
          await _supabase.from('users').select().eq('id', uid).maybeSingle();

      if (userData == null) return null;

      final userType = userData['role'] as String?;

      // Estadísticas base
      final stats = <String, dynamic>{
        'isVerified': userData['isVerified'] ?? false,
        'totalBookings': 0,
        'favorites': userData['favorites'] ?? [],
        'rating': 0.0,
        'completedJobs': 0,
        'memberSince': userData['createdAt'],
        'lastActivity': userData['updatedAt'],
      };

      // Estadísticas específicas por tipo de usuario
      if (userType == 'provider') {
        // Verificar en providers
        final providerData = await _supabase
            .from('providers')
            .select()
            .eq('id', uid)
            .maybeSingle();

        if (providerData != null) {
          stats['rating'] = (providerData['rating'] ?? 0.0).toDouble();
          stats['completedJobs'] = providerData['completedJobs'] ?? 0;
          stats['totalEarnings'] =
              (providerData['totalEarnings'] ?? 0.0).toDouble();
          // activeServices from count of services array or relation?
          // Assuming 'services' is a JSONB array or similar in providerData
          final services = providerData['services'] as List?;
          stats['activeServices'] = services?.length ?? 0;
        }

        // Contar trabajos desde bookings
        final completedBookings = await _supabase
            .from('bookings')
            .count(CountOption.exact)
            .eq('providerId', uid)
            .eq('status', 'completed');

        stats['completedJobs'] = completedBookings;
      } else {
        // Para clientes, contar reservas y favoritos
        final totalBookings = await _supabase
            .from('bookings')
            .count(CountOption.exact)
            .eq('clientId', uid);

        stats['totalBookings'] = totalBookings;

        final favorites = userData['favorites'] as List<dynamic>? ?? [];
        stats['favorites'] = favorites;
      }

      return stats;
    } catch (e) {
      logger.e('Error obteniendo estadísticas: $e');
      return null;
    }
  }

  /// Sube imagen de perfil con progreso
  static Future<Map<String, dynamic>> uploadProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return {'success': false, 'error': 'Archivo no encontrado'};
      }

      // Verificar tamaño del archivo (max 5MB)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        return {
          'success': false,
          'error': 'El archivo es muy grande (máximo 5MB)'
        };
      }

      // Subir a Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = imagePath.split('.').last;
      final fileName = 'profile_images/$userId/$timestamp.$fileExt';

      await _supabase.storage.from('avatars').upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final downloadUrl =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      // Actualizar en todas las colecciones necesarias
      await _updateUserProfileImage(userId, downloadUrl);

      return {
        'success': true,
        'downloadUrl': downloadUrl,
        'message': 'Imagen subida correctamente',
      };
    } catch (e) {
      logger.e('Error subiendo imagen: $e');
      return {
        'success': false,
        'error': 'Error al subir imagen: ${e.toString()}',
      };
    }
  }

  /// Actualiza la URL de imagen en todas las colecciones
  static Future<void> _updateUserProfileImage(
      String userId, String imageUrl) async {
    final timestamp = DateTime.now().toIso8601String();

    final updateData = {
      'photoURL': imageUrl, // Legacy/Auth field
      'profileImage': imageUrl, // DB field
      'profile_image': imageUrl, // Variant DB field
      'updatedAt': timestamp,
    };

    try {
      // Actualizar en users
      await _supabase.from('users').update(updateData).eq('id', userId);

      // Verificar y actualizar en providers si existe
      // Using upsert or update if exists check. Supabase update only updates if exists.
      await _supabase.from('providers').update(updateData).eq('id', userId);

      // Verificar y actualizar en admins si existe
      await _supabase.from('admins').update(updateData).eq('id', userId);

      // Actualizar metadata del usuario en Auth (Supabase Auth doesn't have updatePhotoURL directly on User object same as Firebase)
      // We use updateUser
      await _supabase.auth.updateUser(UserAttributes(
        data: {'picture': imageUrl}, // Storing in metadata
      ));
    } catch (e) {
      logger.e('Error actualizando imagen en tablas: $e');
    }
  }

  /// Obtiene información completa del perfil
  static Future<Map<String, dynamic>?> getProfileInfo([String? userId]) async {
    try {
      final String uid = userId ?? _supabase.auth.currentUser?.id ?? '';
      if (uid.isEmpty) return null;

      // Buscar en order: providers -> admins -> users
      final providerDoc = await _supabase
          .from('providers')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (providerDoc != null) {
        final data = Map<String, dynamic>.from(providerDoc);
        data['userType'] = 'provider';
        data['uid'] = uid;
        return data;
      }

      final adminDoc =
          await _supabase.from('admins').select().eq('id', uid).maybeSingle();

      if (adminDoc != null) {
        final data = Map<String, dynamic>.from(adminDoc);
        data['userType'] = 'admin';
        data['uid'] = uid;
        return data;
      }

      final userDoc =
          await _supabase.from('users').select().eq('id', uid).maybeSingle();

      if (userDoc != null) {
        final data = Map<String, dynamic>.from(userDoc);
        data['userType'] = data['role'] ?? 'client';
        data['uid'] = uid;
        return data;
      }

      return null;
    } catch (e) {
      logger.e('Error obteniendo información del perfil: $e');
      return null;
    }
  }

  /// Actualiza información del perfil
  static Future<bool> updateProfileInfo({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = DateTime.now().toIso8601String();

      // Determinar colección principal
      final userDoc =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();
      if (userDoc == null) return false;

      final userData = userDoc;
      final userRole = userData['role'] as String?;

      // Actualizar en users primero
      await _supabase.from('users').update(data).eq('id', userId);

      // Actualizar en colección específica según el rol
      if (userRole == 'provider') {
        await _supabase.from('providers').update(data).eq('id', userId);
      } else if (userRole == 'admin') {
        await _supabase.from('admins').update(data).eq('id', userId);
      }

      // Actualizar Supabase Auth attributes
      final name = data['name'];
      final email = data['email'];
      final attributes = UserAttributes(
        email: email, // Will trigger confirmation email if changed
        data: name != null ? {'full_name': name, 'name': name} : null,
      );
      if (name != null || email != null) {
        await _supabase.auth.updateUser(attributes);
      }

      return true;
    } catch (e) {
      logger.e('Error actualizando perfil: $e');
      return false;
    }
  }

  /// Elimina imagen anterior del Storage
  static Future<void> deleteOldProfileImage(String imageUrl) async {
    try {
      if (imageUrl.contains('supabase')) {
        // Extract path from URL
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        // Supabase storage URLs: .../storage/v1/object/public/bucket/path/to/file
        // We need 'path/to/file'
        final bucketIndex = pathSegments.indexOf('avatars');
        if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
          final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
          await _supabase.storage.from('avatars').remove([filePath]);
          logger.i('Imagen anterior eliminada del Storage');
        }
      }
    } catch (e) {
      logger.e('Error eliminando imagen anterior: $e');
      // No es crítico, continuar
    }
  }

  /// Verifica el estado del usuario
  static Future<Map<String, dynamic>> getUserStatus(String userId) async {
    try {
      final profileInfo = await getProfileInfo(userId);
      if (profileInfo == null) {
        return {'exists': false};
      }

      return {
        'exists': true,
        'isActive': profileInfo['isActive'] ?? true,
        'isVerified': profileInfo['isVerified'] ?? false,
        'userType': profileInfo['userType'],
        'canUploadImages': true,
        'maxImageSize': 5 * 1024 * 1024, // 5MB
        'supportedFormats': ['jpg', 'jpeg', 'png', 'webp'],
      };
    } catch (e) {
      logger.e('Error verificando estado del usuario: $e');
      return {'exists': false, 'error': e.toString()};
    }
  }
}
