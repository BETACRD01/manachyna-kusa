import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/base_api_service.dart';

class SystemStatusScreen extends StatefulWidget {
  const SystemStatusScreen({super.key});

  @override
  State<SystemStatusScreen> createState() => _SystemStatusScreenState();
}

class _SystemStatusScreenState extends State<SystemStatusScreen> {
  // Estados de verificación
  bool _isLoading = false;

  // Internet
  bool? _hasInternet;
  String _internetStatusMessage = 'Pendiente';

  // Firebase Auth
  bool? _hasFirebaseAuth;
  String _firebaseAuthMessage = 'Pendiente';
  bool _isUserLoggedIn = false;

  // Django Backend
  bool? _hasDjangoBackend;
  String _djangoBackendMessage = 'Pendiente';
  int _backendLatencyMs = 0;

  @override
  void initState() {
    super.initState();
    _runSystemChecks();
  }

  Future<void> _runSystemChecks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _resetStates();
    });

    // 1. Verificar Internet (Connectivity Plus)
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _hasInternet = false;
        _internetStatusMessage = 'No hay conexión de red detectada';
      } else {
        // Podríamos intentar un ping a google.com para estar seguros,
        // pero por ahora confiamos en connectivity + supabase check
        _hasInternet = true;
        _internetStatusMessage = 'Conectado a ${connectivityResult.first.name}';
      }
    } catch (e) {
      _hasInternet = false;
      _internetStatusMessage = 'Error verificando red: $e';
    }
    setState(() {});

    // 2. Verificar Firebase Auth
    try {
      final user = FirebaseAuth.instance.currentUser;
      _hasFirebaseAuth = true;
      _isUserLoggedIn = user != null;
      _firebaseAuthMessage = _isUserLoggedIn 
          ? 'Sesión activa: ${user?.email}' 
          : 'Firebase inicializado (Sin sesión)';
    } catch (e) {
      _hasFirebaseAuth = false;
      _firebaseAuthMessage = 'Error Firebase: $e';
    }
    setState(() {});

    // 3. Verificar Backend Django
    if (_hasInternet == true) {
      try {
        final stopwatch = Stopwatch()..start();
        final apiService = BaseApiService();
        
        // Intentar un ping al backend (usamos un endpoint ligero o el root)
        await apiService.get('providers/categories/'); // Categorías es un endpoint público ligero

        stopwatch.stop();
        _backendLatencyMs = stopwatch.elapsedMilliseconds;
        _hasDjangoBackend = true;
        _djangoBackendMessage = 'Conectado a Django (${_backendLatencyMs}ms)';
      } catch (e) {
        _hasDjangoBackend = false;
        _djangoBackendMessage = 'Error Backend: $e';
      }
    } else {
      _hasDjangoBackend = false;
      _djangoBackendMessage = 'Sin internet para verificar backend';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetStates() {
    _hasInternet = null;
    _internetStatusMessage = 'Verificando...';
    _hasFirebaseAuth = null;
    _firebaseAuthMessage = 'Verificando...';
    _hasDjangoBackend = null;
    _djangoBackendMessage = 'Esperando conexión...';
    _backendLatencyMs = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del Sistema'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runSystemChecks,
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatusCard(
                  title: 'Conectividad Internet',
                  icon: Icons.wifi,
                  status: _hasInternet,
                  message: _internetStatusMessage,
                ),
                const SizedBox(height: 12),
                _buildStatusCard(
                  title: 'Firebase Authentication',
                  icon: Icons.lock_outline,
                  status: _hasFirebaseAuth,
                  message: _firebaseAuthMessage,
                  trailing: _isUserLoggedIn 
                      ? const Icon(Icons.person, color: Colors.blue, size: 18)
                      : null,
                ),
                const SizedBox(height: 12),
                _buildStatusCard(
                  title: 'Backend Django',
                  icon: Icons.dns,
                  status: _hasDjangoBackend,
                  message: _djangoBackendMessage,
                  trailing: _backendLatencyMs > 0
                      ? Chip(
                          label: Text('${_backendLatencyMs}ms'),
                          backgroundColor: _getLatencyColor(_backendLatencyMs),
                          labelStyle: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        )
                      : null,
                ),
                const SizedBox(height: 30),
                if (_hasInternet == true &&
                    _hasFirebaseAuth == true &&
                    _hasDjangoBackend == true)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 30),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Todos los sistemas operativos. Puedes iniciar sesión con confianza.',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Color _getLatencyColor(int ms) {
    if (ms < 200) return Colors.green;
    if (ms < 500) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatusCard({
    required String title,
    required IconData icon,
    required bool? status,
    required String message,
    Widget? trailing,
  }) {
    Color statusColor;
    IconData statusIcon;

    if (status == true) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == false) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withAlpha(30),
          child: Icon(icon, color: statusColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 8),
            ],
            Icon(statusIcon, color: statusColor),
          ],
        ),
      ),
    );
  }
}
