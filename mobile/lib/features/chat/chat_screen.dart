import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../data/models/message_model.dart';
import '../../shared/widgets/chat/chat_app_bar.dart';
import '../../shared/widgets/chat/typing_indicator.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

/// Pantalla de chat (proveedor ⇄ cliente) con buenas prácticas:
/// - Resolución automática de chat si no llega `chatId` (usa `getOrCreateChat`)
/// - Carga reactiva con Stream + estados de empty/error
/// - UI más fluida y defensiva
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.chatId,
    required this.otherUserName,
    this.otherUserId,
    this.bookingId,
    this.userType, // Agregado parámetro userType para mantener el rol del usuario
  });

  final String? chatId;
  final String otherUserName;
  final String? otherUserId;
  final String? bookingId;
  final String? userType; // Nuevo campo para almacenar el tipo de usuario

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  String? _currentChatId;
  bool _isTyping = false;
  final bool _otherUserTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _initializeChat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  /// Si vienes sin chatId pero con otherUserId, intenta crear/recuperar el chat.
  Future<void> _initializeChat() async {
    if (widget.chatId != null) {
      _currentChatId = widget.chatId;
      if (mounted) setState(() {});
      return;
    }

    if (widget.otherUserId == null) return;

    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    final currentUser = auth.currentUser;

    if (currentUser == null) return;

    try {
      final id = await chat.getOrCreateChat(
        currentUserId: currentUser.uid,
        otherUserId: widget.otherUserId!,
        currentUserName: auth.userData?['fullName'] ?? 'Usuario',
        otherUserName: widget.otherUserName,
        bookingId: widget.bookingId,
      );
      if (!mounted) return;
      setState(() => _currentChatId = id);
    } catch (e, st) {
      logger.e('Error initializing chat', error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al inicializar el chat. Inténtalo de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser;

    // Usuario no autenticado
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Usuario no autenticado')),
      );
    }

    // Sin chat resuelto aún → loading
    if (_currentChatId == null) {
      return Scaffold(
        appBar: ChatAppBar(
          userName: widget.otherUserName,
          isOnline: false,
          isTyping: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.98),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: ChatAppBar(
          userName: widget.otherUserName,
          isOnline: true,
          isTyping: _otherUserTyping,
          onCallPressed: _makeCall,
          onVideoCallPressed: _makeVideoCall,
          onInfoPressed: _showChatInfo,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Lista de mensajes
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    return StreamBuilder<List<Message>>(
                      stream: Stream.fromFuture(
                          chatProvider.getChatMessages(_currentChatId!)),
                      builder: (context, snapshot) {
                        final state = snapshot.connectionState;

                        if (state == ConnectionState.waiting) {
                          return const _CenteredLoader();
                        }

                        if (snapshot.hasError) {
                          return _ErrorState(
                            onRetry: () => setState(() {}),
                          );
                        }

                        final messages = snapshot.data ?? const <Message>[];
                        if (messages.isEmpty) {
                          return _EmptyState(userName: widget.otherUserName);
                        }

                        // Marcar como leídos post frame (evita rebuild loops)
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          chatProvider.markMessagesAsRead(
                            _currentChatId!,
                          );
                        });

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: ListView.builder(
                            key: ValueKey(messages.length),
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            itemCount:
                                messages.length + (_otherUserTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Indicador "escribiendo" al final
                              if (_otherUserTyping && index == 0) {
                                return TypingIndicatorBubble(
                                  isVisible: _otherUserTyping,
                                  userName: widget.otherUserName,
                                );
                              }

                              final msgIndex =
                                  _otherUserTyping ? index - 1 : index;
                              final msg = messages[msgIndex];
                              final isMe = msg.senderId == currentUser.uid;

                              final previous = msgIndex < messages.length - 1
                                  ? messages[msgIndex + 1]
                                  : null;
                              final next =
                                  msgIndex > 0 ? messages[msgIndex - 1] : null;

                              return RepaintBoundary(
                                child: MessageBubble(
                                  message: msg,
                                  isMe: isMe,
                                  previousMessageSenderId: previous?.senderId,
                                  nextMessageSenderId: next?.senderId,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Input de chat
              ChatInput(
                chatId: _currentChatId!,
                currentUserId: currentUser.uid,
                currentUserName: auth.userData?['fullName'] ?? 'Usuario',
                onTyping: () {
                  if (!_isTyping) setState(() => _isTyping = true);
                },
                onStopTyping: () {
                  if (_isTyping) setState(() => _isTyping = false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Acciones de AppBar / BottomSheet ----------

  void _makeCall() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de llamadas próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _makeVideoCall() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de videollamadas próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showChatInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChatInfoSheet(
        otherUserName: widget.otherUserName,
        bookingId: widget.bookingId,
        onCall: _makeCall,
        onVideo: _makeVideoCall,
        onShowBooking: _showBookingInfo,
        onBlock: _blockUser,
      ),
    );
  }

  void _showBookingInfo() {
    Navigator.of(context).maybePop();
    if (!mounted) return;

    if (widget.bookingId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Información del trabajo: ${widget.bookingId}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay trabajo asociado')),
      );
    }
  }

  void _blockUser() {
    Navigator.of(context).maybePop();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de bloqueo próximamente')),
    );
  }
}

// =================== Widgets auxiliares (UI/Estados) ===================

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: color.error),
            const SizedBox(height: 12),
            Text(
              'Error al cargar mensajes',
              style: TextStyle(color: color.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: onVar),
            const SizedBox(height: 16),
            Text(
              'No hay mensajes aún',
              style: TextStyle(fontSize: 18, color: onVar),
            ),
            const SizedBox(height: 8),
            Text(
              'Saluda a $userName para iniciar la conversación',
              style: TextStyle(fontSize: 14, color: onVar),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInfoSheet extends StatelessWidget {
  const _ChatInfoSheet({
    required this.otherUserName,
    required this.bookingId,
    required this.onCall,
    required this.onVideo,
    required this.onShowBooking,
    required this.onBlock,
  });

  final String otherUserName;
  final String? bookingId;
  final VoidCallback onCall;
  final VoidCallback onVideo;
  final VoidCallback onShowBooking;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Material(
          color: theme.colorScheme.surface,
          elevation: 2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Avatar y nombre
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.12),
                            child: Text(
                              (otherUserName.isNotEmpty
                                      ? otherUserName[0]
                                      : 'U')
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            otherUserName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _OnlineDot(),
                              const SizedBox(width: 6),
                              Text(
                                'En línea',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Acciones
                    _ActionTile(
                      icon: Icons.phone,
                      title: 'Llamar',
                      onTap: onCall,
                    ),
                    _ActionTile(
                      icon: Icons.videocam,
                      title: 'Videollamada',
                      onTap: onVideo,
                    ),
                    _ActionTile(
                      icon: Icons.info_outline,
                      title: bookingId != null
                          ? 'Información del trabajo'
                          : 'Sin trabajo asociado',
                      onTap: onShowBooking,
                    ),
                    _ActionTile(
                      icon: Icons.block,
                      title: 'Bloquear usuario',
                      color: theme.colorScheme.error,
                      onTap: onBlock,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = color ?? theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(color: fg),
                ),
              ),
              Icon(Icons.chevron_right, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
    );
  }
}
