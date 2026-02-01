import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String? userAvatar;
  final bool isOnline;
  final bool isTyping;
  final VoidCallback? onCallPressed;
  final VoidCallback? onVideoCallPressed;
  final VoidCallback? onInfoPressed;

  const ChatAppBar({
    super.key,
    required this.userName,
    this.userAvatar,
    this.isOnline = false,
    this.isTyping = false,
    this.onCallPressed,
    this.onVideoCallPressed,
    this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      scrolledUnderElevation: 0,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Divider(
          height: 0.5,
          thickness: 0.5,
          color: Colors.black.withValues(alpha: 0.1),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF007AFF)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            userName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: -0.4,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          _buildStatusText(),
        ],
      ),
      actions: [
        if (onCallPressed != null)
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF007AFF)),
            onPressed: onCallPressed,
          ),
        if (onVideoCallPressed != null)
          IconButton(
            icon: const Icon(Icons.videocam, color: Color(0xFF007AFF)),
            onPressed: onVideoCallPressed,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatusText() {
    if (isTyping) {
      return const Text(
        'escribiendo...',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF8E8E93),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      isOnline ? 'En línea' : 'Desconectado',
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF8E8E93),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
