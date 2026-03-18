import 'dart:async';
import 'package:flutter/material.dart';
import 'app_initializer.dart';
import '../../app.dart';
import '../../shared/widgets/initialization_error_screen.dart';
import '../utils/app_logger.dart';

/// The root widget during application startup.
/// Manages the initialization state machine and handles retries without recursion.
class AppStartupWrapper extends StatefulWidget {
  const AppStartupWrapper({super.key});

  @override
  State<AppStartupWrapper> createState() => _AppStartupWrapperState();
}

class _AppStartupWrapperState extends State<AppStartupWrapper> {
  bool _isInitialized = false;
  String? _errorMessage;
  int _attemptCount = 1;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      AppLogger.i('AppStartupWrapper: Iniciando inicialización (Intento $_attemptCount)...');
      
      // AppInitializer already has its own internal retry logic (3 attempts)
      // If it throws, it means it failed after all its internal retries.
      await AppInitializer.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e('AppStartupWrapper: Error crítico tras reintentos internos', e, stackTrace);
      
      if (mounted) {
        setState(() {
          _errorMessage = _sanitizeError(e);
        });
      }
    }
  }

  String _sanitizeError(Object e) {
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('timeout') || errorStr.contains('deadline')) {
      return 'La conexión tardó demasiado. Por favor, verifica tu internet.';
    } else if (errorStr.contains('socket') || errorStr.contains('network')) {
      return 'Error de red. Asegúrate de estar conectado a internet.';
    } else if (errorStr.contains('configuration') || errorStr.contains('firebase')) {
      return 'Error de configuración del servicio. Contacta a soporte.';
    }
    return 'Ocurrió un error inesperado al iniciar los servicios.';
  }

  void _handleRetry() {
    setState(() {
      _attemptCount++;
    });
    _startInitialization();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return const MyApp();
    }

    if (_errorMessage != null) {
      return InitializationErrorScreen(
        onRetry: _handleRetry,
        attempt: _attemptCount,
        error: _errorMessage,
      );
    }

    // Default loading/splash state
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF007AFF)),
              SizedBox(height: 24),
              Text(
                'Iniciando Manachyna Kusa...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
