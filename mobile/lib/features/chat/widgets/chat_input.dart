import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Asegúrate de tener esta importación
import '../../../providers/chat_provider.dart';

class ChatInput extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String currentUserName;
  final VoidCallback? onTyping;
  final VoidCallback? onStopTyping;

  const ChatInput({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.currentUserName,
    this.onTyping,
    this.onStopTyping,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _recordingAnimationController;
  late Animation<double> _recordingAnimation;
  bool _isTyping = false;
  bool _showAttachments = false;
  // Timer? _recordingTimer; // Para el contador de tiempo de grabación

  @override
  void initState() {
    super.initState();
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _recordingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _recordingAnimationController,
      curve: Curves.easeInOut,
    ));

    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _recordingAnimationController.dispose();
    // _recordingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final isTyping = _textController.text.trim().isNotEmpty;
    if (isTyping != _isTyping) {
      setState(() {
        _isTyping = isTyping;
      });

      if (isTyping) {
        widget.onTyping?.call();
      } else {
        widget.onStopTyping?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9FB),
            border: Border(
              top: BorderSide(
                color: Colors.black.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Panel de adjuntos
                if (_showAttachments) _buildAttachmentsPanel(chatProvider),

                // Input principal
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment
                        .end, // Alinea al final para el TextField
                    children: [
                      // Botón de adjuntos (+)
                      IconButton(
                        icon: Icon(
                          _showAttachments ? Icons.close : Icons.add,
                          color: const Color(0xFF007AFF),
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _showAttachments = !_showAttachments;
                          });
                          if (!_showAttachments) {
                            _focusNode.requestFocus();
                          } else {
                            _focusNode.unfocus();
                          }
                        },
                      ),

                      // Campo de texto
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            maxLines: 5,
                            minLines: 1,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: chatProvider.isRecording
                                  ? 'Grabando...'
                                  : 'Mensaje',
                              hintStyle: const TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              suffixIcon: chatProvider.isRecording
                                  ? const Icon(Icons.mic,
                                      color: Colors.red, size: 20)
                                  : null,
                            ),
                            onSubmitted: (_) => _sendTextMessage(chatProvider),
                            enabled: !chatProvider.isRecording,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Botón de enviar o grabar
                      if (_isTyping || chatProvider.isUploading)
                        _buildSendButton(chatProvider)
                      else
                        _buildRecordButton(chatProvider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentsPanel(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentButton(
            icon: Icons.camera_alt,
            label: 'Cámara',
            color: Colors.blue,
            onTap: () => _sendImageMessage(chatProvider, ImageSource.camera),
          ),
          _buildAttachmentButton(
            icon: Icons.photo_library,
            label: 'Galería',
            color: Colors.green,
            onTap: () => _sendImageMessage(chatProvider, ImageSource.gallery),
          ),
          _buildAttachmentButton(
            icon: Icons.location_on,
            label: 'Ubicación',
            color: Colors.red,
            onTap: () => _sendLocationMessage(chatProvider),
          ),
          // Puedes añadir más opciones aquí, por ejemplo, documentos
          // _buildAttachmentButton(
          //   icon: Icons.insert_drive_file,
          //   label: 'Documento',
          //   color: Colors.purple,
          //   onTap: () { /* Lógica para enviar documento */ },
          // ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton(ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4, right: 8),
      child: IconButton(
        icon: chatProvider.isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF007AFF)),
                ),
              )
            : const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: 20,
              ),
        onPressed: chatProvider.isUploading
            ? null
            : () => _sendTextMessage(chatProvider),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildRecordButton(ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4, right: 8),
      child: GestureDetector(
        onLongPressStart: (_) => _startRecording(chatProvider),
        onLongPressEnd: (_) => _stopRecording(chatProvider),
        onLongPressCancel: () => _cancelRecording(chatProvider),
        child: AnimatedBuilder(
          animation: _recordingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: chatProvider.isRecording ? _recordingAnimation.value : 1.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: chatProvider.isRecording
                      ? Colors.red
                      : const Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  chatProvider.isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ========================================
  // MÉTODOS DE ENVÍO
  // ========================================

  Future<void> _sendTextMessage(ChatProvider chatProvider) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _isTyping = false;
      _showAttachments = false;
    });
    _focusNode.unfocus(); // Ocultar teclado después de enviar

    try {
      await chatProvider.sendTextMessage(
        chatId: widget.chatId,
        content: text,
      );
    } catch (e) {
      _showErrorSnackBar('Error al enviar mensaje: $e');
    }
  }

  Future<void> _sendImageMessage(
      ChatProvider chatProvider, ImageSource source) async {
    setState(() {
      _showAttachments = false;
    });
    _focusNode.unfocus(); // Ocultar teclado

    try {
      await chatProvider.sendImageMessage(
        chatId: widget.chatId,
        source: source,
      );
    } catch (e) {
      _showErrorSnackBar('Error al enviar imagen: $e');
    }
  }

  Future<void> _sendLocationMessage(ChatProvider chatProvider) async {
    setState(() {
      _showAttachments = false;
    });
    _focusNode.unfocus(); // Ocultar teclado

    try {
      await chatProvider.sendLocationMessage(
        chatId: widget.chatId,
        latitude: 0.0, //
        longitude: 0.0,
      );
    } catch (e) {
      _showErrorSnackBar('Error al enviar ubicación: $e');
    }
  }

  // ========================================
  // MÉTODOS DE GRABACIÓN
  // ========================================

  Future<void> _startRecording(ChatProvider chatProvider) async {
    try {
      await chatProvider.startRecording();
      _recordingAnimationController.repeat(reverse: true);
      // _startRecordingTimer(); // Iniciar contador
    } catch (e) {
      _showErrorSnackBar('Error al iniciar grabación: $e');
    }
  }

  Future<void> _stopRecording(ChatProvider chatProvider) async {
    try {
      _recordingAnimationController.stop();
      _recordingAnimationController.reset();
      // _stopRecordingTimer(); // Detener contador

      await chatProvider.stopRecording();
    } catch (e) {
      _showErrorSnackBar('Error al detener grabación: $e');
    }
  }

  Future<void> _cancelRecording(ChatProvider chatProvider) async {
    try {
      _recordingAnimationController.stop();
      _recordingAnimationController.reset();
      // _stopRecordingTimer(); // Detener contador
      await chatProvider.cancelRecording();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  // String _formatDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, '0');
  //   final minutes = twoDigits(duration.inMinutes.remainder(60));
  //   final seconds = twoDigits(duration.inSeconds.remainder(60));
  //   return '$minutes:$seconds';
  // }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
