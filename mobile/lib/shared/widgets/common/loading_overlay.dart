// lib/shared/widgets/common/loading_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

class LoadingOverlay extends StatefulWidget {
  final String message;
  final bool isVisible;
  final List<String>? progressMessages;

  const LoadingOverlay({
    super.key,
    this.message = 'Cargando...',
    this.isVisible = true,
    this.progressMessages,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _currentMessage = '';
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
    _initializeAnimations();
    _startMessageCycle();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    if (widget.isVisible) {
      _fadeController.forward();
    }
  }

  void _startMessageCycle() {
    if (widget.progressMessages != null &&
        widget.progressMessages!.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted && widget.isVisible) {
          setState(() {
            _messageIndex =
                (_messageIndex + 1) % widget.progressMessages!.length;
            _currentMessage = widget.progressMessages![_messageIndex];
          });
          _startMessageCycle();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // FONDO DIFUMINADO (BLUR)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // INDICADOR DE IOS
                  const CupertinoActivityIndicator(
                    radius: 16,
                    color: Color(0xFF3C3C43),
                  ),
                  const SizedBox(height: 16),

                  // MENSAJE PRINCIPAL
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _currentMessage,
                      key: ValueKey(_currentMessage),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Por favor espera...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF3C3C43),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper para mostrar el loading
class LoadingHelper {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context, {
    String message = 'Cargando...',
    List<String>? progressMessages,
  }) {
    hide();
    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingOverlay(
        message: message,
        progressMessages: progressMessages,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

extension BuildContextLoading on BuildContext {
  void showLoading({
    String message = 'Cargando...',
    List<String>? progressMessages,
  }) {
    LoadingHelper.show(this,
        message: message, progressMessages: progressMessages);
  }

  void hideLoading() {
    LoadingHelper.hide();
  }
}

// WIDGET ESPECIALIZADO PARA LOGIN
class LoginLoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String currentMessage;

  const LoginLoadingOverlay({
    super.key,
    required this.isVisible,
    required this.currentMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return LoadingOverlay(
      isVisible: isVisible,
      message: currentMessage,
      progressMessages: const [
        'Conectando...',
        'Verificando datos...',
        'Iniciando sesión...',
        '¡Casi listo!',
      ],
    );
  }
}
