import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';

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

  // Supabase Auth
  bool? _hasSupabaseAuth;
  String _supabaseAuthMessage = 'Pendiente';

  // Supabase DB
  bool? _hasSupabaseDB;
  String _supabaseDBMessage = 'Pendiente';
  int _dbLatencyMs = 0;

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

    // 2. Verificar Supabase Auth Config
    try {
      final isConfigured = await SupabaseConfig.checkConnection();
      if (isConfigured) {
        _hasSupabaseAuth = true;
        _supabaseAuthMessage = 'Cliente inicializado correctamente';
      } else {
        _hasSupabaseAuth = false;
        _supabaseAuthMessage = 'Error en configuración (API Key/URL)';
      }
    } catch (e) {
      _hasSupabaseAuth = false;
      _supabaseAuthMessage = 'Excepción: $e';
    }
    setState(() {});

    // 3. Verificar Latencia DB (Real Request)
    if (_hasInternet == true && _hasSupabaseAuth == true) {
      try {
        final stopwatch = Stopwatch()..start();

        // Hacemos una consulta muy ligera.
        // Nota: esto requiere que la tabla 'categories' o 'services' sea pública
        // o que tengamos sesión. Si falla por RLS, sabremos que conecta pero no autoriza.
        // Usamos count para minimizar transferencia de datos.

        // Intentaremos leer la configuración de idioma o health check si existiera.
        // Como fallback genérico intentamos leer auth session que es local/remoto hibrido
        // o count de una tabla que sepamos que existe.

        // Usamos 'users' y seleccionamos 'uid' como sugirió el error
        await Supabase.instance.client
            .from('users')
            .select('uid')
            .limit(1)
            .maybeSingle();

        stopwatch.stop();
        _dbLatencyMs = stopwatch.elapsedMilliseconds;
        _hasSupabaseDB = true;
        _supabaseDBMessage = 'Respuesta recibida en ${_dbLatencyMs}ms';
      } catch (e) {
        _hasSupabaseDB = false;
        // Si es error de row security policy, es buena señal de conexión al menos
        if (e.toString().contains('policy') ||
            e.toString().contains('permission')) {
          _hasSupabaseDB = true;
          _supabaseDBMessage = 'Conectado (Restricción de acceso detectada)';
        } else {
          _supabaseDBMessage = 'Error de conexión DB: $e';
        }
      }
    } else {
      _hasSupabaseDB = false;
      _supabaseDBMessage = 'No se puede verificar (Falta internet o Auth)';
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
    _hasSupabaseAuth = null;
    _supabaseAuthMessage = 'Verificando...';
    _hasSupabaseDB = null;
    _supabaseDBMessage = 'Esperando conexión...';
    _dbLatencyMs = 0;
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
                  title: 'Supabase Servidor',
                  icon: Icons.cloud_queue,
                  status: _hasSupabaseAuth,
                  message: _supabaseAuthMessage,
                ),
                const SizedBox(height: 12),
                _buildStatusCard(
                  title: 'Base de Datos',
                  icon: Icons.storage,
                  status: _hasSupabaseDB,
                  message: _supabaseDBMessage,
                  trailing: _dbLatencyMs > 0
                      ? Chip(
                          label: Text('${_dbLatencyMs}ms'),
                          backgroundColor: _getLatencyColor(_dbLatencyMs),
                          labelStyle: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        )
                      : null,
                ),
                const SizedBox(height: 30),
                if (_hasInternet == true &&
                    _hasSupabaseAuth == true &&
                    _hasSupabaseDB == true)
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
