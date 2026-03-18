import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
// import removed
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../data/services/base_api_service.dart';
import '../core/utils/app_logger.dart';

class ChatProvider extends ChangeNotifier {
  final BaseApiService _apiService = BaseApiService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isRecording = false;
  bool _isUploading = false;

  bool get isRecording => _isRecording;
  bool get isUploading => _isUploading;

  // ============================
  // FETCH / POLLING
  // ============================

  Future<List<Chat>> getMyChats() async {
    try {
      final response = await _apiService.get('chats/');
      return (response as List).map((map) => Chat.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('Error obteniendo chats: $e');
      return [];
    }
  }

  Future<List<Message>> getChatMessages(String chatId) async {
    try {
      final response = await _apiService.get('chats/$chatId/messages/');
      return (response as List).map((map) => Message.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('Error obteniendo mensajes: $e');
      return [];
    }
  }

  // ============================
  // CREAR / OBTENER CHAT
  // ============================

  Future<String> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
    String? bookingId,
  }) async {
    try {
      final response = await _apiService.post('chats/get-or-create/', body: {
        'other_user_id': otherUserId,
        'booking_id': bookingId,
      });
      return response['id'].toString();
    } catch (e) {
      AppLogger.e('Error creating/getting chat in Django: $e');
      rethrow;
    }
  }

  // ============================
  // ENVIAR MENSAJES
  // ============================

  Future<void> sendTextMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      await _apiService.post('chats/$chatId/messages/', body: {
        'content': content.trim(),
        'type': 'text',
      });
      notifyListeners();
    } catch (e) {
      AppLogger.e('Error enviando mensaje de texto: $e');
      rethrow;
    }
  }

  Future<void> sendImageMessage({
    required String chatId,
    required ImageSource source,
  }) async {
    try {
      _isUploading = true;
      notifyListeners();

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (image == null) return;

      AppLogger.w(
          'Subida de imágenes a Django aún requiere implementación multipart.');

      await _apiService.post('chats/$chatId/messages/', body: {
        'content': 'Imagen (Pendiente subida)',
        'type': 'image',
        // 'image_url': ...
      });
    } catch (e) {
      AppLogger.e('Error enviando imagen: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Mismos métodos para Audio y Localización pero adaptados a Django API...
  // (Omitidos por brevedad o implementados de forma similar a sendTextMessage)

  Future<void> markChatAsRead(String chatId) async {
    try {
      await _apiService.post('chats/$chatId/read/', body: {});
    } catch (e) {
      // Ignorar errores menores de lectura
    }
  }

  Future<List<Chat>> getUserChats(String userId) async {
    return getMyChats();
  }

  Future<bool> isUserBlocked(String currentUserId, String otherUserId) async {
    return false;
  }

  Future<void> archiveChat(String chatId) async {
    try {
      await _apiService.post('chats/$chatId/archive/', body: {});
    } catch (e) {
      AppLogger.e('Error archiving chat: $e');
    }
  }

  Future<void> unarchiveChat(String chatId) async {
    try {
      await _apiService.post('chats/$chatId/unarchive/', body: {});
    } catch (e) {
      AppLogger.e('Error unarchiving chat: $e');
    }
  }

  Future<void> blockUser(String currentUserId, String otherUserId) async {
    try {
      await _apiService.post('users/$currentUserId/block/',
          body: {'otherUserId': otherUserId});
    } catch (e) {
      AppLogger.e('Error blocking user: $e');
    }
  }

  Future<void> unblockUser(String currentUserId, String otherUserId) async {
    try {
      await _apiService.post('users/$currentUserId/unblock/',
          body: {'otherUserId': otherUserId});
    } catch (e) {
      AppLogger.e('Error unblocking user: $e');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _apiService.delete('chats/$chatId/');
    } catch (e) {
      AppLogger.e('Error deleting chat: $e');
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    return markChatAsRead(chatId);
  }

  Future<void> sendLocationMessage({
    required String chatId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _apiService.post('chats/$chatId/messages/', body: {
        'content': 'Location: $latitude, $longitude',
        'type': 'location',
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      AppLogger.e('Error sending location: $e');
    }
  }

  Future<void> startRecording() async {
    _isRecording = true;
    notifyListeners();
  }

  Future<String?> stopRecording() async {
    _isRecording = false;
    notifyListeners();
    return null;
  }

  Future<void> cancelRecording() async {
    _isRecording = false;
    notifyListeners();
  }
}
