import 'package:flutter/material.dart';

// Ajusta estas rutas si tu estructura difiere: lib/features/{provider,chat}/...
import '../chat/chat_list_screen.dart';
import '../chat/chat_screen.dart';

/// Pantalla "Ganancias" convertida en Hub de Chat para proveedor.
/// - Con argumentos (chatId / otherUserId) => muestra ChatScreen.
/// - Sin argumentos => muestra ChatListScreen.
/// Además añade transición suave y un helper para abrir chats.
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  static const routeName = '/earnings';

  /// Helper para abrir el chat de forma consistente
  static Future<void> openChat(
    BuildContext context, {
    String? chatId,
    String? otherUserId,
    String? otherUserName,
    String? bookingId,
  }) {
    return Navigator.pushNamed(
      context,
      routeName,
      arguments: {
        if (chatId != null) 'chatId': chatId,
        if (otherUserId != null) 'otherUserId': otherUserId,
        if (otherUserName != null) 'otherUserName': otherUserName,
        if (bookingId != null) 'bookingId': bookingId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    // Parseo seguro de argumentos
    String? chatId;
    String? otherUserId;
    String otherUserName = 'Chat';
    String? bookingId;

    if (args is Map) {
      final maybeName = (args['otherUserName'] as String?)?.trim();
      chatId = args['chatId'] as String?;
      otherUserId = args['otherUserId'] as String?;
      bookingId = args['bookingId'] as String?;
      if (maybeName != null && maybeName.isNotEmpty) {
        otherUserName = maybeName;
      }
    }

    // Decide qué vista mostrar
    final showDetail = (chatId != null) || (otherUserId != null);

    // Animación de transición entre lista y detalle
    return DecoratedBox(
      decoration: BoxDecoration(
        // Fondo sutil para elevar el look&feel
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.98),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutQuad,
          switchOutCurve: Curves.easeInQuad,
          transitionBuilder: (child, anim) {
            // Fade + ligero scale para sensación de fluidez
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.985, end: 1.0).animate(anim),
                child: child,
              ),
            );
          },
          child: showDetail
              ? KeyedSubtree(
                  key: const ValueKey('chat_detail'),
                  child: ChatScreen(
                    chatId: chatId,
                    otherUserId: otherUserId,
                    otherUserName: otherUserName,
                    bookingId: bookingId,
                  ),
                )
              : const KeyedSubtree(
                  key: ValueKey('chat_list'),
                  child: ChatListScreen(),
                ),
        ),
      ),
    );
  }
}
