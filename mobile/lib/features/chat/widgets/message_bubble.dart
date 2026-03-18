import 'package:flutter/material.dart';
import '../../../data/models/message_model.dart';
import 'image_message.dart';
import 'audio_message.dart';
import 'location_message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String? previousMessageSenderId;
  final String? nextMessageSenderId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.previousMessageSenderId,
    this.nextMessageSenderId,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = previousMessageSenderId != message.senderId;
    final isLast = nextMessageSenderId != message.senderId;

    return Container(
      margin: EdgeInsets.only(
        left: isMe ? 64 : 12,
        right: isMe ? 12 : 64,
        top: isFirst ? 10 : 2,
        bottom: isLast ? 10 : 2,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && isFirst)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF007AFF) : const Color(0xFFE9E9EB),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : (isLast ? 4 : 20)),
                bottomRight: Radius.circular(!isMe ? 20 : (isLast ? 4 : 20)),
              ),
            ),
            child: _buildMessageContent(context),
          ),
          if (isLast)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isMe ? 0 : 4,
                right: isMe ? 4 : 0,
              ),
              child: Text(
                _formatTime(message.timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(context);
      case MessageType.image:
        return ImageMessage(message: message, isMe: isMe);
      case MessageType.audio:
        return AudioMessage(message: message, isMe: isMe);
      case MessageType.location:
        return LocationMessage(message: message, isMe: isMe);
      case MessageType.file:
        return _buildFileMessage(context);
    }
  }

  Widget _buildTextMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        message.content,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black,
          fontSize: 16,
          height: 1.3,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildFileMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_file,
            color: isMe ? Colors.white : Colors.grey[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.metadata?['fileName'] ?? 'Archivo',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Ayer ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
