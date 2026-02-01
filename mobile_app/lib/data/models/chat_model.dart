class Chat {
  final String id;
  final List<String> participants;
  final String? bookingId;

  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;

  final Map<String, int> unreadCount;
  final Map<String, String> participantNames;

  final bool isActive;

  /// Control de visibilidad por usuario (soft-delete / ocultar para un usuario)
  final List<String> visibleFor;

  Chat({
    required this.id,
    required this.participants,
    this.bookingId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.unreadCount,
    required this.participantNames,
    this.isActive = true,
    required this.visibleFor,
  });

  factory Chat.fromMap(Map<String, dynamic> data) {
    List<String> asStringList(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? <String>[];

    Map<String, String> asStringMap(dynamic v) {
      final src = (v as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      return src.map((k, val) => MapEntry(k, val?.toString() ?? ''));
    }

    Map<String, int> asIntMap(dynamic v) {
      final src = (v as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      return src.map((k, val) => MapEntry(k, (val as num?)?.toInt() ?? 0));
    }

    DateTime asDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) return DateTime.parse(v);
      return DateTime.now();
    }

    final participants = asStringList(data['participants']);
    final participantNames = asStringMap(data['participantNames']);
    final unreadCount = asIntMap(data['unreadCount']);
    final visibleForRaw = asStringList(data['visibleFor']);

    return Chat(
      id: data['id']?.toString() ?? '',
      participants: participants,
      bookingId: (data['booking_id']?.toString().isEmpty ?? true)
          ? null
          : data['booking_id'].toString(),
      lastMessage: data['last_message']?.toString() ?? '',
      lastMessageTime: asDate(data['last_message_time']),
      lastMessageSenderId: data['last_message_sender_id']?.toString() ?? '',
      unreadCount: unreadCount,
      participantNames: participantNames,
      isActive: (data['is_active'] as bool?) ?? true,
      visibleFor: visibleForRaw.isEmpty ? participants : visibleForRaw,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'booking_id': bookingId,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
      'last_message_sender_id': lastMessageSenderId,
      'unread_count': unreadCount,
      'participant_names': participantNames,
      'is_active': isActive,
      'visible_for': visibleFor,
    };
  }

  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Usuario';
  }

  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }

  Chat copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    Map<String, String>? participantNames,
    bool? isActive,
    List<String>? visibleFor,
  }) {
    return Chat(
      id: id,
      participants: participants,
      bookingId: bookingId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      participantNames: participantNames ?? this.participantNames,
      isActive: isActive ?? this.isActive,
      visibleFor: visibleFor ?? this.visibleFor,
    );
  }
}
