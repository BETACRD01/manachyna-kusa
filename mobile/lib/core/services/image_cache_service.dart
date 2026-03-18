// lib/core/services/image_cache_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageCacheService {
  static const String _cacheFolder = 'image_cache';
  static const Duration _cacheExpiry = Duration(days: 7); // Cache por 7 días

  /// Obtiene imagen desde cache o descarga si no existe
  static Future<String?> getCachedImagePath(String imageUrl) async {
    try {
      // Generar nombre único para el archivo
      final fileName = _generateFileName(imageUrl);
      final cacheDir = await _getCacheDirectory();
      final imagePath = '${cacheDir.path}/$fileName';
      final imageFile = File(imagePath);

      // Verificar si existe y no ha expirado
      if (await imageFile.exists()) {
        final stats = await imageFile.stat();
        final isExpired =
            DateTime.now().difference(stats.modified) > _cacheExpiry;

        if (!isExpired) {
          debugPrint('Imagen cacheada encontrada: $fileName');
          return imagePath;
        } else {
          // Imagen expirada, eliminar
          await imageFile.delete();
          debugPrint('Cache expirado, eliminando: $fileName');
        }
      }

      // Descargar y cachear nueva imagen
      return await _downloadAndCacheImage(imageUrl, imagePath);
    } catch (e) {
      debugPrint('Error en cache de imagen: $e');
      return null;
    }
  }

  /// Descarga imagen y la guarda en cache
  static Future<String?> _downloadAndCacheImage(
      String imageUrl, String savePath) async {
    try {
      debugPrint('Descargando imagen: $imageUrl');

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'ManachinaKusa/1.0.0',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final imageFile = File(savePath);
        await imageFile.writeAsBytes(response.bodyBytes);

        debugPrint('Imagen cacheada: ${imageFile.path}');
        return savePath;
      } else {
        debugPrint('Error descarga: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error descargando imagen: $e');
      return null;
    }
  }

  /// Genera nombre único para archivo basado en URL
  static String _generateFileName(String imageUrl) {
    final bytes = utf8.encode(imageUrl);
    final digest = sha256.convert(bytes);
    final extension = _getFileExtension(imageUrl);
    return '$digest$extension';
  }

  /// Obtiene extensión del archivo desde URL
  static String _getFileExtension(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    if (path.contains('.jpg') || path.contains('.jpeg')) return '.jpg';
    if (path.contains('.png')) return '.png';
    if (path.contains('.gif')) return '.gif';
    if (path.contains('.webp')) return '.webp';

    return '.jpg'; // Por defecto
  }

  /// Obtiene directorio de cache
  static Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheFolder');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// Limpia cache expirado
  static Future<void> cleanExpiredCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final files = await cacheDir.list().toList();

      int deletedCount = 0;

      for (final file in files) {
        if (file is File) {
          final stats = await file.stat();
          final isExpired =
              DateTime.now().difference(stats.modified) > _cacheExpiry;

          if (isExpired) {
            await file.delete();
            deletedCount++;
          }
        }
      }

      if (deletedCount > 0) {
        debugPrint('Cache limpiado: $deletedCount archivos eliminados');
      }
    } catch (e) {
      debugPrint('Error limpiando cache: $e');
    }
  }

  /// Obtiene tamaño total del cache
  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final files = await cacheDir.list().toList();

      int totalSize = 0;
      for (final file in files) {
        if (file is File) {
          final stats = await file.stat();
          totalSize += stats.size;
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error calculando tamaño cache: $e');
      return 0;
    }
  }

  /// Formatea tamaño en bytes a texto legible
  static String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Limpia todo el cache
  static Future<void> clearAllCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('Todo el cache eliminado');
      }
    } catch (e) {
      debugPrint('Error eliminando cache: $e');
    }
  }
}
