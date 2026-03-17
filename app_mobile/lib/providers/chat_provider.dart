import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final loc.Location _location = loc.Location();
  final Uuid _uuid = const Uuid();

  bool _isRecording = false;
  bool _isUploading = false;
  String? _recordingPath;

  bool get isRecording => _isRecording;
  bool get isUploading => _isUploading;

  // ============================
  // STREAMS
  // ============================

  Stream<List<Chat>> getUserChats(String userId) {
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('last_message_time', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((map) => Chat.fromMap(map))
              .where((chat) => chat.participants.contains(userId))
              .where((chat) => chat.isActive)
              .where((chat) => chat.visibleFor.contains(userId))
              .toList();
        });
  }

  Stream<List<Message>> getChatMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chatId', chatId)
        .order('timestamp', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data.map((map) => Message.fromMap(map)).toList();
        });
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
      var query = _supabase
          .from('chats')
          .select()
          .contains('participants', [currentUserId]);

      if (bookingId != null) {
        query = query.eq('booking_id', bookingId);
      }

      final List<dynamic> response = await query;

      for (final doc in response) {
        final chat = Chat.fromMap(doc);
        if (chat.participants.contains(otherUserId) &&
            (bookingId == null || chat.bookingId == bookingId)) {
          if (!chat.visibleFor.contains(currentUserId)) {
            final updatedVisibleFor = List<String>.from(chat.visibleFor)
              ..add(currentUserId);
            await _supabase
                .from('chats')
                .update({'visible_for': updatedVisibleFor}).eq('id', chat.id);
          }
          return chat.id;
        }
      }

      final now = DateTime.now().toIso8601String();
      final chatId = _uuid.v4();

      final chatData = {
        'id': chatId,
        'participants': [currentUserId, otherUserId],
        'participant_names': {
          currentUserId: currentUserName,
          otherUserId: otherUserName,
        },
        'booking_id': bookingId,
        'last_message': '',
        'last_message_time': now,
        'last_message_sender_id': '',
        'unread_count': {currentUserId: 0, otherUserId: 0},
        'is_active': true,
        'visible_for': [currentUserId, otherUserId],
        'created_at': now,
      };

      await _supabase.from('chats').insert(chatData);
      return chatId;
    } catch (e) {
      debugPrint('Error creating/getting chat: $e');
      rethrow;
    }
  }

  // ============================
  // ENVIAR MENSAJES
  // ============================

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      final msg = Message(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: content.trim(),
        type: MessageType.text,
        timestamp: DateTime.now(),
      );
      await _addMessageToChat(chatId, msg);
    } catch (e) {
      debugPrint('Error sending text message: $e');
      rethrow;
    }
  }

  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String senderName,
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
      if (image == null) {
        _isUploading = false;
        notifyListeners();
        return;
      }

      final fileExt = image.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExt';
      final uploadPath = '$chatId/$fileName';

      final imageUrl = await _uploadFile(
        File(image.path),
        uploadPath,
        contentType: 'image/$fileExt',
      );

      final msg = Message(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: imageUrl,
        type: MessageType.image,
        timestamp: DateTime.now(),
        metadata: {
          'fileName': image.name,
          'size': await File(image.path).length(),
          'path': uploadPath,
        },
      );

      await _addMessageToChat(chatId, msg);
    } catch (e) {
      debugPrint('Error sending image: $e');
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> sendLocationMessage({
    required String chatId,
    required String senderId,
    required String senderName,
  }) async {
    try {
      _isUploading = true;
      notifyListeners();

      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw Exception('Servicio de ubicación deshabilitado');
        }
      }

      var permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      final locationData = await _location.getLocation();

      final msg = Message(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: 'Ubicación compartida',
        type: MessageType.location,
        timestamp: DateTime.now(),
        metadata: {
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'accuracy': locationData.accuracy,
          'locationName': 'Ubicación actual',
        },
      );

      await _addMessageToChat(chatId, msg);
    } catch (e) {
      debugPrint('Error sending location: $e');
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // ============================
  // AUDIO
  // ============================

  Future<void> startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Permisos de micrófono denegados');
      }

      final tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/${_uuid.v4()}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );

      _isRecording = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting recording: $e');
      rethrow;
    }
  }

  Future<void> stopRecording({
    required String chatId,
    required String senderId,
    required String senderName,
  }) async {
    try {
      if (!_isRecording || _recordingPath == null) return;

      final path = await _audioRecorder.stop();
      _isRecording = false;
      notifyListeners();

      if (path == null) return;

      _isUploading = true;
      notifyListeners();

      final file = File(path);
      final fileSize = await file.length();

      final fileName = '${_uuid.v4()}.m4a';
      final uploadPath = '$chatId/$fileName';

      final audioUrl = await _uploadFile(
        file,
        uploadPath,
        contentType: 'audio/mp4',
      );

      final msg = Message(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: audioUrl,
        type: MessageType.audio,
        timestamp: DateTime.now(),
        metadata: {
          'duration': 0,
          'size': fileSize,
          'path': uploadPath,
        },
      );

      await _addMessageToChat(chatId, msg);

      try {
        await file.delete();
      } catch (_) {}
      _recordingPath = null;
    } catch (e) {
      _isRecording = false;
      debugPrint('Error stopping recording: $e');
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _audioRecorder.stop();
        _isRecording = false;
      }
      if (_recordingPath != null) {
        final f = File(_recordingPath!);
        if (await f.exists()) await f.delete();
        _recordingPath = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  // ============================
  // GESTIÓN DE CHATS
  // ============================

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    return markChatAsRead(chatId, userId);
  }

  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      final res = await _supabase
          .from('chats')
          .select('unread_count')
          .eq('id', chatId)
          .single();
      final unreadCountRaw = res['unread_count'] as Map<String, dynamic>? ?? {};

      final updatedUnreadCount = Map<String, dynamic>.from(unreadCountRaw);
      updatedUnreadCount[userId] = 0;

      await _supabase.from('chats').update({
        'unread_count': updatedUnreadCount,
      }).eq('id', chatId);
    } catch (e) {
      // debugPrint('Error marking chat as read: $e');
    }
  }

  Future<void> archiveChat(String chatId) async {
    try {
      await _supabase.from('chats').update({
        'is_archived': true,
        'archived_at': DateTime.now().toIso8601String(),
      }).eq('id', chatId);
    } catch (e) {
      debugPrint('Error archiving chat: $e');
      rethrow;
    }
  }

  Future<void> unarchiveChat(String chatId) async {
    try {
      await _supabase.from('chats').update({
        'is_archived': false,
        'archived_at': null,
      }).eq('id', chatId);
    } catch (e) {
      debugPrint('Error unarchiving chat: $e');
      rethrow;
    }
  }

  Future<void> hideChatForUser(String chatId, String userId) async {
    try {
      final res = await _supabase
          .from('chats')
          .select('visible_for, unread_count')
          .eq('id', chatId)
          .single();
      final List<String> visibleFor =
          List<String>.from(res['visible_for'] ?? []);
      final unreadCount = Map<String, dynamic>.from(res['unread_count'] ?? {});

      visibleFor.remove(userId);
      unreadCount[userId] = 0;

      await _supabase.from('chats').update({
        'visible_for': visibleFor,
        'unread_count': unreadCount,
      }).eq('id', chatId);
    } catch (e) {
      debugPrint('Error hiding chat: $e');
      rethrow;
    }
  }

  Future<void> deleteChat(String chatId, {required String requesterId}) async {
    try {
      final msgs = await _supabase
          .from('messages')
          .select()
          .eq('chatId', chatId)
          .or('type.eq.image,type.eq.audio');

      for (final doc in msgs) {
        final path = doc['metadata']?['path'];
        if (path != null) {
          try {
            await _supabase.storage.from('chat-media').remove([path]);
          } catch (e) {
            debugPrint('Storage delete error: $e');
          }
        }
      }

      await _supabase.from('chats').delete().eq('id', chatId);
    } catch (e) {
      debugPrint('Error deleting chat: $e');
      await hideChatForUser(chatId, requesterId);
    }
  }

  Future<void> deleteMessage({
    required String chatId,
    required Message message,
    required String requesterId,
  }) async {
    try {
      if (message.type == MessageType.image ||
          message.type == MessageType.audio) {
        final path = message.metadata?['path'];
        if (path != null) {
          try {
            await _supabase.storage.from('chat-media').remove([path]);
          } catch (e) {
            debugPrint('Storage delete error: $e');
          }
        }
      }

      await _supabase.from('messages').delete().eq('id', message.id);
      await _refreshChatLastMessage(chatId);
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }

  Future<void> _refreshChatLastMessage(String chatId) async {
    final List<dynamic> lastMsgs = await _supabase
        .from('messages')
        .select()
        .eq('chatId', chatId)
        .order('timestamp', ascending: false)
        .limit(1);

    if (lastMsgs.isEmpty) {
      await _supabase.from('chats').update({
        'last_message': '',
        'last_message_sender_id': '',
        'last_message_time': DateTime.now().toIso8601String(),
      }).eq('id', chatId);
    } else {
      final m = Message.fromMap(lastMsgs.first);
      await _supabase.from('chats').update({
        'last_message': m.getDisplayContent(),
        'last_message_sender_id': m.senderId,
        'last_message_time': m.timestamp.toIso8601String(),
      }).eq('id', chatId);
    }
  }

  Future<void> blockUser(String currentUserId, String userToBlockId) async {
    try {
      // Using a 'blocked_users' table or array in 'users'.
      // Assuming 'users' has 'blocked_users' array column for simplicity.
      // Or better, a separate table 'user_blocks' (blocker_id, blocked_id).
      // I'll assume separate table 'user_blocks'.
      await _supabase.from('user_blocks').insert({
        'blocker_id': currentUserId,
        'blocked_id': userToBlockId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error blocking user: $e');
    }
  }

  Future<void> unblockUser(String currentUserId, String userToUnblockId) async {
    try {
      await _supabase
          .from('user_blocks')
          .delete()
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', userToUnblockId);
    } catch (e) {
      debugPrint('Error unblocking user: $e');
    }
  }

  Future<bool> isUserBlocked(String currentUserId, String otherUserId) async {
    try {
      final res = await _supabase
          .from('user_blocks')
          .select()
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', otherUserId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getBlockedUsers(String currentUserId) async {
    try {
      final res = await _supabase
          .from('user_blocks')
          .select('blocked_id')
          .eq('blocker_id', currentUserId);
      return (res as List).map((e) => e['blocked_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // ============================
  // PRIVADOS
  // ============================

  Future<void> _addMessageToChat(String chatId, Message message) async {
    await _supabase.from('messages').insert(message.toMap());

    final chatRes = await _supabase
        .from('chats')
        .select('participants, unread_count')
        .eq('id', chatId)
        .single();
    final participants = List<String>.from(chatRes['participants'] ?? []);
    final unreadCount =
        Map<String, dynamic>.from(chatRes['unread_count'] ?? {});

    for (final p in participants) {
      if (p != message.senderId) {
        unreadCount[p] = (unreadCount[p] as int? ?? 0) + 1;
      }
    }

    await _supabase.from('chats').update({
      'last_message': message.getDisplayContent(),
      'last_message_time': message.timestamp.toIso8601String(),
      'last_message_sender_id': message.senderId,
      'unread_count': unreadCount,
    }).eq('id', chatId);
  }

  Future<String> _uploadFile(
    File file,
    String path, {
    String? contentType,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      await _supabase.storage.from('chat-media').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      return _supabase.storage.from('chat-media').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }

  // Compatibility helper
  Stream<List<Chat>> searchChats(String query) {
    return _supabase.from('chats').stream(primaryKey: ['id']).map((list) {
      // Very basic client side search implementation
      return list.map((m) => Chat.fromMap(m)).where((c) {
        return c.participantNames.values
            .any((name) => name.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }

  Stream<List<Chat>> getArchivedChats(String userId) {
    return getUserChats(userId).map((list) => list
        .where((c) => false)
        .toList()); // TODO: Implement archived logic in Chat model
  }
}
