enum MessageType {
  text,
  image,
  audio,
  location,
  file,
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    DateTime asDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) return DateTime.parse(v);
      return DateTime.now();
    }

    return Message(
      id: data['id']?.toString() ?? '',
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      content: data['content'] ?? '',
      type: _getMessageTypeFromString(data['type'] ?? 'text'),
      timestamp: asDate(data['timestamp']),
      isRead: data['isRead'] ?? false,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  static MessageType _getMessageTypeFromString(String typeString) {
    switch (typeString) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'location':
        return MessageType.location;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isAudio => type == MessageType.audio;
  bool get isLocation => type == MessageType.location;
  bool get isFile => type == MessageType.file;

  // Para mensajes de imagen
  String? get imageUrl => isImage ? content : null;

  // Para mensajes de audio
  String? get audioUrl => isAudio ? content : null;
  int? get audioDuration {
    if (!isAudio || metadata == null) return null;
    return metadata!['duration'] as int?;
  }

  // Para mensajes de ubicación
  double? get latitude {
    if (!isLocation || metadata == null) return null;
    return metadata!['latitude'] as double?;
  }

  double? get longitude {
    if (!isLocation || metadata == null) return null;
    return metadata!['longitude'] as double?;
  }

  String? get locationName {
    if (!isLocation || metadata == null) return null;
    return metadata!['locationName'] as String?;
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  String getDisplayContent() {
    switch (type) {
      case MessageType.text:
        return content;
      case MessageType.image:
        return 'Imagen';
      case MessageType.audio:
        return 'Audio';
      case MessageType.location:
        return 'Ubicación';
      case MessageType.file:
        return 'Archivo';
    }
  }
}
