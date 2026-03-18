import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../data/models/chat_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _reloadToken = 0;
  String _query = '';
  final Set<String> _deletingChats = {}; // Track chats being deleted
  final Set<String> _deletedChats = {}; // Track successfully deleted chats

  Future<void> _onRefresh() async {
    setState(() {
      _reloadToken++;
      _deletingChats.clear(); // Clear deletion states on refresh
      _deletedChats.clear();
    });
    await Future.delayed(const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chats')),
        body: const Center(child: Text('Usuario no autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () async {
              final q = await showSearch<String?>(
                context: context,
                delegate: _ChatSearchDelegate(initialQuery: _query),
              );
              if (!mounted) return;
              if (q != null) setState(() => _query = q);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          return KeyedSubtree(
            key: ValueKey(_reloadToken),
            child: StreamBuilder<List<Chat>>(
              stream: Stream.fromFuture(chatProvider.getUserChats(currentUser.uid)),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const _CenteredLoader();
                }

                if (snap.hasError) {
                  return _ErrorState(
                    error: '${snap.error}',
                    onRetry: () => setState(() => _reloadToken++),
                  );
                }

                final allChats = snap.data ?? const <Chat>[];

                // Filter out deleted chats immediately
                final activeChats = allChats
                    .where((chat) => !_deletedChats.contains(chat.id))
                    .toList();

                final filteredChats = _query.trim().isEmpty
                    ? activeChats
                    : activeChats.where((c) {
                        final name = c
                            .getOtherParticipantName(currentUser.uid)
                            .toLowerCase();
                        return name.contains(_query.toLowerCase());
                      }).toList();

                if (filteredChats.isEmpty && _deletingChats.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        _EmptyState(
                          hasQuery: _query.isNotEmpty,
                          onClearQuery: () {
                            if (!mounted) return;
                            setState(() => _query = '');
                          },
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: ListView.separated(
                      key: ValueKey(
                          '${filteredChats.length}|$_query|${_deletingChats.length}'),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredChats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final isDeleting = _deletingChats.contains(chat.id);

                        return RepaintBoundary(
                          child: Column(
                            children: [
                              _ChatTile(
                                chat: chat,
                                currentUserId: currentUser.uid,
                                isDeleting: isDeleting, // Pass deletion state
                                onTap: isDeleting
                                    ? null // Disable tap when deleting
                                    : () => _openChat(
                                        context, chat, currentUser.uid),
                                onLongPress: isDeleting
                                    ? null // Disable long press when deleting
                                    : () => _showChatOptions(
                                        context, chat, currentUser.uid),
                              ),
                              if (index < filteredChats.length - 1)
                                const Padding(
                                  padding: EdgeInsets.only(left: 84),
                                  child: Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    color: Color(0xFFE0E0E0),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, Chat chat, String currentUserId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chat.id,
          otherUserName: chat.getOtherParticipantName(currentUserId),
          otherUserId: chat.getOtherParticipantId(currentUserId),
          bookingId: chat.bookingId,
        ),
      ),
    );
  }

  Future<void> _showChatOptions(
    BuildContext context,
    Chat chat,
    String currentUserId,
  ) async {
    final otherParticipantName = chat.getOtherParticipantName(currentUserId);
    final chatProvider = context.read<ChatProvider>();

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Hero(
                tag: 'chat_avatar_${chat.id}',
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  child: Text(
                    (otherParticipantName.isNotEmpty
                            ? otherParticipantName[0]
                            : 'U')
                        .toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              title: Text(
                otherParticipantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Opciones de conversación',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 16),
            _OptionTile(
              icon: Icons.mark_chat_read,
              title: 'Marcar como leído',
              color: Colors.blue,
              onTap: () async {
                Navigator.pop(context);
                await _markAsRead(context, chat, currentUserId);
              },
            ),
            _OptionTile(
              icon: Icons.archive_outlined,
              title: 'Archivar chat',
              color: Colors.orange,
              onTap: () async {
                Navigator.pop(context);
                await _archiveChat(context, chat);
              },
            ),
            FutureBuilder<bool>(
              future: chatProvider.isUserBlocked(
                currentUserId,
                chat.getOtherParticipantId(currentUserId),
              ),
              builder: (context, snapshot) {
                final isBlocked = snapshot.data ?? false;
                return _OptionTile(
                  icon: isBlocked ? Icons.lock_open : Icons.block,
                  title: isBlocked ? 'Desbloquear usuario' : 'Bloquear usuario',
                  color: isBlocked ? Colors.green : Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    if (isBlocked) {
                      await _unblockUser(context, chat, currentUserId);
                    } else {
                      await _showBlockUserDialog(context, chat, currentUserId);
                    }
                  },
                );
              },
            ),
            _OptionTile(
              icon: Icons.delete_outline,
              title: 'Eliminar chat',
              color: Colors.red,
              onTap: () async {
                Navigator.pop(context);
                await _showDeleteChatDialog(context, chat, currentUserId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(
      BuildContext context, Chat chat, String currentUserId) async {
    final chatProvider = context.read<ChatProvider>();
    try {
      await chatProvider.markChatAsRead(chat.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat marcado como leído'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar como leído: $e')),
      );
    }
  }

  Future<void> _archiveChat(BuildContext context, Chat chat) async {
    final chatProvider = context.read<ChatProvider>();
    try {
      await chatProvider.archiveChat(chat.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chat archivado'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () async {
              await chatProvider.unarchiveChat(chat.id);
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al archivar: $e')),
      );
    }
  }

  Future<void> _showBlockUserDialog(
      BuildContext context, Chat chat, String currentUserId) async {
    final otherParticipantName = chat.getOtherParticipantName(currentUserId);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 8),
            Text('Bloquear usuario'),
          ],
        ),
        content: Text(
          '¿Bloquear a $otherParticipantName?\n\n'
          '• No podrá enviarte mensajes\n'
          '• El chat será archivado\n'
          '• Podrás desbloquear desde Configuración',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _blockUser(context, chat, currentUserId);
            },
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
  }

  Future<void> _blockUser(
      BuildContext context, Chat chat, String currentUserId) async {
    final chatProvider = context.read<ChatProvider>();
    final otherUserId = chat.getOtherParticipantId(currentUserId);

    try {
      await chatProvider.blockUser(currentUserId, otherUserId);
      await chatProvider.archiveChat(chat.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario bloqueado'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al bloquear: $e')),
      );
    }
  }

  Future<void> _unblockUser(
      BuildContext context, Chat chat, String currentUserId) async {
    final chatProvider = context.read<ChatProvider>();
    final otherUserId = chat.getOtherParticipantId(currentUserId);

    try {
      await chatProvider.unblockUser(currentUserId, otherUserId);
      await chatProvider.unarchiveChat(chat.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario desbloqueado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al desbloquear: $e')),
      );
    }
  }

  Future<void> _showDeleteChatDialog(
      BuildContext context, Chat chat, String currentUserId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Eliminar chat'),
          ],
        ),
        content: const Text(
          '¿Seguro que deseas eliminar esta conversación?\n\n'
          '• Se borrarán todos los mensajes y archivos\n'
          '• No podrás deshacer esta acción',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteChat(context, chat, currentUserId);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChat(
      BuildContext context, Chat chat, String currentUserId) async {
    final chatProvider = context.read<ChatProvider>();

    // Mark as deleting immediately
    setState(() {
      _deletingChats.add(chat.id);
    });

    try {
      // Delete the chat
      await chatProvider.deleteChat(chat.id);

      if (!context.mounted) return;

      // Mark as successfully deleted
      setState(() {
        _deletingChats.remove(chat.id);
        _deletedChats.add(chat.id);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chat eliminado correctamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Actualizar',
            textColor: Colors.white,
            onPressed: () => _onRefresh(),
          ),
        ),
      );

      // Auto-refresh after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _onRefresh();
        }
      });
    } catch (e) {
      if (!context.mounted) return;

      // Remove from deleting state on error
      setState(() {
        _deletingChats.remove(chat.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () => _deleteChat(context, chat, currentUserId),
          ),
        ),
      );
    }
  }
}

// =================== Widgets de soporte/UI ===================

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.currentUserId,
    required this.isDeleting,
    required this.onTap,
    required this.onLongPress,
  });

  final Chat chat;
  final String currentUserId;
  final bool isDeleting;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otherName = chat.getOtherParticipantName(currentUserId);
    final unreadCount = chat.getUnreadCountForUser(currentUserId);
    final isUnread = unreadCount > 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.05),
      highlightColor: theme.colorScheme.primary.withValues(alpha: 0.03),
      child: Container(
        color: isDeleting
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.1)
            : (isUnread ? const Color(0xFFF9F9FB) : Colors.transparent),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Hero(
              tag: 'chat_avatar_${chat.id}',
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isDeleting
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : const Color(0xFFF2F2F7),
                    child: isDeleting
                        ? Icon(Icons.delete_outline,
                            color: theme.colorScheme.error)
                        : Text(
                            (otherName.isNotEmpty ? otherName[0] : 'U')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF3A3A3C),
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                  ),
                  if (isDeleting)
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isDeleting ? 'Eliminando...' : otherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w600,
                            color: isDeleting
                                ? theme.colorScheme.error
                                : Colors.black,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!isDeleting)
                        Text(
                          _formatMessageTime(chat.lastMessageTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: isUnread
                                ? const Color(0xFF007AFF)
                                : const Color(0xFF8E8E93),
                            fontWeight:
                                isUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (chat.lastMessageSenderId == currentUserId &&
                          !isDeleting) ...[
                        const Icon(Icons.done_all,
                            size: 16, color: Color(0xFF8E8E93)),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          isDeleting
                              ? 'Chat siendo eliminado...'
                              : chat.lastMessage.isNotEmpty
                                  ? chat.lastMessage
                                  : 'Nueva conversación',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDeleting
                                ? theme.colorScheme.error.withValues(alpha: 0.7)
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                      if (isUnread && !isDeleting) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF007AFF),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (msgDay == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (msgDay == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    } else if (msgDay.isAfter(today.subtract(const Duration(days: 7)))) {
      const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return weekdays[dateTime.weekday - 1];
    } else {
      final yy = dateTime.year.toString().substring(2);
      return '${dateTime.day}/${dateTime.month}/$yy';
    }
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar chats',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery, required this.onClearQuery});
  final bool hasQuery;
  final VoidCallback onClearQuery;

  @override
  Widget build(BuildContext context) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Icon(Icons.chat_bubble_outline, size: 80, color: onVar),
        const SizedBox(height: 16),
        Text(
          hasQuery ? 'No hay resultados' : 'No tienes conversaciones',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: onVar),
        ),
        const SizedBox(height: 8),
        Text(
          hasQuery
              ? 'Intenta con otro nombre'
              : 'Tus conversaciones con clientes aparecerán aquí',
        ),
        if (hasQuery) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onClearQuery,
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar búsqueda'),
          ),
        ],
      ],
    );
  }
}

// =================== Search ===================

class _ChatSearchDelegate extends SearchDelegate<String?> {
  _ChatSearchDelegate({String? initialQuery}) {
    query = initialQuery ?? '';
  }

  @override
  String get searchFieldLabel => 'Buscar por nombre…';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Limpiar',
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Volver',
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final value = query.trim();
    close(context, value.isEmpty ? null : value);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final base = <String>['Juan', 'María', 'Plomería', 'Electricidad'];
    final suggestions = query.isEmpty
        ? base
        : base
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        final text = suggestions[i];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(text),
          onTap: () {
            query = text;
            showResults(context);
          },
        );
      },
    );
  }
}
