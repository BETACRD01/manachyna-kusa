// lib/features/admin/settings_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
// Configuraciones generales
final Map<String, dynamic> _generalSettings = {
  'appName': 'Mañachyna Kusa',
  'appVersion': '1.0.0',
  'supportEmail': 'soporte@manachynakusa.com',
  'maintenanceMode': false,
  'allowNewRegistrations': true,
  'requireEmailVerification': true,
};

// Configuraciones de pagos
final Map<String, dynamic> _paymentSettings = {
  'platformCommission': 15.0,
  'paymentMethods': ['tarjeta', 'efectivo', 'transferencia'],
  'minimumAmount': 10.0,
  'maximumAmount': 500.0,
  'autoPayoutEnabled': true,
  'payoutThreshold': 100.0,
};

// Configuraciones de notificaciones
final Map<String, dynamic> _notificationSettings = {
  'emailNotifications': true,
  'pushNotifications': true,
  'smsNotifications': false,
  'newUserNotifications': true,
  'bookingNotifications': true,
  'paymentNotifications': true,
  'systemAlerts': true,
};

// Configuraciones de seguridad
final Map<String, dynamic> _securitySettings = {
  'twoFactorAuth': false,
  'sessionTimeout': 30,
  'passwordMinLength': 8,
  'requireSpecialChars': true,
  'maxLoginAttempts': 5,
  'ipWhitelist': <String>[],
};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // 6 tabs ahora
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    // Simular carga de configuraciones desde base de datos
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    // Simular guardado de configuraciones
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuraciones guardadas exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: 'Guardar cambios',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'General'),
            Tab(icon: Icon(Icons.payment), text: 'Pagos'),
            Tab(icon: Icon(Icons.notifications), text: 'Notificaciones'),
            Tab(icon: Icon(Icons.security), text: 'Seguridad'),
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
            Tab(icon: Icon(Icons.info), text: 'Información'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildPaymentTab(),
          _buildNotificationTab(),
          _buildSecurityTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Información de la Aplicación'),
          _buildSettingsCard([
            _buildTextFieldSetting(
              'Nombre de la App',
              _generalSettings['appName'],
              (value) => _generalSettings['appName'] = value,
            ),
            _buildTextFieldSetting(
              'Versión',
              _generalSettings['appVersion'],
              (value) => _generalSettings['appVersion'] = value,
            ),
            _buildTextFieldSetting(
              'Email de Soporte',
              _generalSettings['supportEmail'],
              (value) => _generalSettings['supportEmail'] = value,
              keyboardType: TextInputType.emailAddress,
            ),
          ]),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Control de Acceso'),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Modo Mantenimiento',
              'Desactiva temporalmente la aplicación para usuarios',
              _generalSettings['maintenanceMode'],
              (value) => setState(() => _generalSettings['maintenanceMode'] = value),
              isWarning: true,
            ),
            _buildSwitchSetting(
              'Permitir Nuevos Registros',
              'Los usuarios pueden crear nuevas cuentas',
              _generalSettings['allowNewRegistrations'],
              (value) => setState(() => _generalSettings['allowNewRegistrations'] = value),
            ),
            _buildSwitchSetting(
              'Verificación de Email Requerida',
              'Los usuarios deben verificar su email al registrarse',
              _generalSettings['requireEmailVerification'],
              (value) => setState(() => _generalSettings['requireEmailVerification'] = value),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Información del Sistema'),
          _buildSystemInfoCard(),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Comisiones'),
          _buildSettingsCard([
            _buildSliderSetting(
              'Comisión de la Plataforma (%)',
              'Porcentaje que cobra la plataforma por cada servicio',
              _paymentSettings['platformCommission'],
              0.0,
              30.0,
              (value) => setState(() => _paymentSettings['platformCommission'] = value),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Límites de Pago'),
          _buildSettingsCard([
            _buildNumberFieldSetting(
              'Monto Mínimo (\$)',
              _paymentSettings['minimumAmount'],
              (value) => _paymentSettings['minimumAmount'] = value,
            ),
            _buildNumberFieldSetting(
              'Monto Máximo (\$)',
              _paymentSettings['maximumAmount'],
              (value) => _paymentSettings['maximumAmount'] = value,
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Pagos Automáticos'),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Pagos Automáticos Habilitados',
              'Los proveedores reciben pagos automáticamente',
              _paymentSettings['autoPayoutEnabled'],
              (value) => setState(() => _paymentSettings['autoPayoutEnabled'] = value),
            ),
            _buildNumberFieldSetting(
              'Umbral de Pago Automático (\$)',
              _paymentSettings['payoutThreshold'],
              (value) => _paymentSettings['payoutThreshold'] = value,
              enabled: _paymentSettings['autoPayoutEnabled'],
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Métodos de Pago'),
          _buildPaymentMethodsCard(),
        ],
      ),
    );
  }

  Widget _buildNotificationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Canales de Notificación'),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Notificaciones por Email',
              'Enviar notificaciones importantes por email',
              _notificationSettings['emailNotifications'],
              (value) => setState(() => _notificationSettings['emailNotifications'] = value),
            ),
            _buildSwitchSetting(
              'Notificaciones Push',
              'Enviar notificaciones push a dispositivos móviles',
              _notificationSettings['pushNotifications'],
              (value) => setState(() => _notificationSettings['pushNotifications'] = value),
            ),
            _buildSwitchSetting(
              'Notificaciones SMS',
              'Enviar notificaciones por mensaje de texto',
              _notificationSettings['smsNotifications'],
              (value) => setState(() => _notificationSettings['smsNotifications'] = value),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Tipos de Notificación'),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Nuevos Usuarios',
              'Notificar cuando se registren nuevos usuarios',
              _notificationSettings['newUserNotifications'],
              (value) => setState(() => _notificationSettings['newUserNotifications'] = value),
            ),
            _buildSwitchSetting(
              'Reservas',
              'Notificar sobre nuevas reservas y cambios',
              _notificationSettings['bookingNotifications'],
              (value) => setState(() => _notificationSettings['bookingNotifications'] = value),
            ),
            _buildSwitchSetting(
              'Pagos',
              'Notificar sobre transacciones y pagos',
              _notificationSettings['paymentNotifications'],
              (value) => setState(() => _notificationSettings['paymentNotifications'] = value),
            ),
            _buildSwitchSetting(
              'Alertas del Sistema',
              'Notificar sobre errores y problemas técnicos',
              _notificationSettings['systemAlerts'],
              (value) => setState(() => _notificationSettings['systemAlerts'] = value),
            ),
          ]),

          const SizedBox(height: 24),
          _buildTestNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Autenticación'),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Autenticación de Dos Factores',
              'Requiere verificación adicional para administradores',
              _securitySettings['twoFactorAuth'],
              (value) => setState(() => _securitySettings['twoFactorAuth'] = value),
            ),
            _buildDropdownSetting(
              'Tiempo de Sesión (minutos)',
              'Tiempo antes de cerrar sesión automáticamente',
              _securitySettings['sessionTimeout'],
              [15, 30, 60, 120, 240],
              (value) => setState(() => _securitySettings['sessionTimeout'] = value),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Políticas de Contraseña'),
          _buildSettingsCard([
            _buildDropdownSetting(
              'Longitud Mínima',
              'Número mínimo de caracteres para contraseñas',
              _securitySettings['passwordMinLength'],
              [6, 8, 10, 12],
              (value) => setState(() => _securitySettings['passwordMinLength'] = value),
            ),
            _buildSwitchSetting(
              'Caracteres Especiales Requeridos',
              'Las contraseñas deben incluir símbolos especiales',
              _securitySettings['requireSpecialChars'],
              (value) => setState(() => _securitySettings['requireSpecialChars'] = value),
            ),
            _buildDropdownSetting(
              'Máximo Intentos de Login',
              'Número de intentos fallidos antes de bloquear cuenta',
              _securitySettings['maxLoginAttempts'],
              [3, 5, 10],
              (value) => setState(() => _securitySettings['maxLoginAttempts'] = value),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Seguridad Avanzada'),
          _buildSecurityActionsCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          return Column(
            children: [
              child,
              if (index < children.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextFieldSetting(
    String title,
    String value,
    Function(String) onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberFieldSetting(
    String title,
    double value,
    Function(double) onChanged, {
    bool enabled = true,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: TextField(
        controller: TextEditingController(text: value.toString()),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: TextInputType.number,
        enabled: enabled,
        onChanged: (text) {
          final newValue = double.tryParse(text);
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    bool isWarning = false,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: isWarning ? Colors.orange : Colors.purple,
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${min.toInt()}%'),
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: ((max - min) / 1).round(),
                  label: '${value.toStringAsFixed(1)}%',
                  onChanged: onChanged,
                  activeColor: Colors.purple,
                ),
              ),
              Text('${max.toInt()}%'),
            ],
          ),
          Center(
            child: Text(
              'Actual: ${value.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting<T>(
    String title,
    String subtitle,
    T value,
    List<T> options,
    Function(T) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            key: ValueKey(value),
            initialValue: value,
            items: options.map((option) {
              return DropdownMenuItem<T>(
                value: option,
                child: Text(option.toString()),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Estado del Servidor', 'Operativo', Colors.green),
          _buildInfoRow('Base de Datos', 'Conectada', Colors.green),
          _buildInfoRow('Último Backup', '2 horas ago', Colors.blue),
          _buildInfoRow('Usuarios Activos', '156 usuarios', Colors.purple),
          _buildInfoRow('Espacio en Disco', '67% usado', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard() {
    final methods = _paymentSettings['paymentMethods'] as List<String>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métodos Habilitados',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ...methods.map((method) => _buildPaymentMethodRow(method)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddPaymentMethodDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Agregar Método', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodRow(String method) {
    final icons = {
      'tarjeta': Icons.credit_card,
      'efectivo': Icons.money,
      'transferencia': Icons.account_balance,
    };
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icons[method] ?? Icons.payment, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(child: Text(method.toUpperCase())),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _removePaymentMethod(method),
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Probar Notificaciones',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sendTestEmail,
                  icon: const Icon(Icons.email, color: Colors.white),
                  label: const Text('Email', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sendTestPush,
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  label: const Text('Push', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones de Seguridad',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showLogAuditDialog,
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text('Ver Logs de Auditoría', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showActiveSessionsDialog,
              icon: const Icon(Icons.devices, color: Colors.white),
              label: const Text('Sesiones Activas', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showBackupDialog,
              icon: const Icon(Icons.backup, color: Colors.white),
              label: const Text('Crear Backup', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _removePaymentMethod(String method) {
    setState(() {
      (_paymentSettings['paymentMethods'] as List<String>).remove(method);
    });
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Método de Pago'),
        content: const Text('Funcionalidad próximamente disponible'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _sendTestEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email de prueba enviado'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _sendTestPush() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación push enviada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showLogAuditDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logs de Auditoría'),
      content: const SizedBox(
        height: 200,
        child: SingleChildScrollView(
          child: Text(
            '2024-06-28 10:30:15 - Admin login: admin@example.com\n'
            '2024-06-28 10:25:42 - User approved: provider_123\n'
            '2024-06-28 10:20:18 - Settings updated: payment commission\n'
            '2024-06-28 10:15:33 - User deleted: user_456\n'
            '2024-06-28 10:10:07 - Backup created: daily_backup_001\n'
            '2024-06-28 10:05:22 - System maintenance started\n',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _exportLogs();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Exportar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _exportLogs() async {
  try {
    final logs = _getAuditLogs();
    final timestamp = DateTime.now();
    final fileName = 'audit_logs_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}.txt';
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(logs);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs exportados: $fileName'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Compartir',
          onPressed: () => _shareLogs(file.path),
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al exportar: $e')),
    );
  }
}


void _shareLogs(String filePath) async {
  try {
    // Using SharePlus - the recommended replacement
    await Share.share(
      'Logs de auditoría del sistema',
      subject: 'Logs de Auditoría - Mañachyna Kusa',
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al compartir: $e')),
    );
  }
}

String _getAuditLogs() {
  return 'LOGS DE AUDITORÍA - MAÑACHYNA KUSA\n'
      'Generado: ${DateTime.now().toString().split(' ')[0]}\n'
      '${'=' * 50}\n\n'
      '2024-06-28 10:30:15 - Admin login: admin@example.com\n'
      '2024-06-28 10:25:42 - User approved: provider_123\n'
      '2024-06-28 10:20:18 - Settings updated: payment commission\n'
      '2024-06-28 10:15:33 - User deleted: user_456\n'
      '2024-06-28 10:10:07 - Backup created: daily_backup_001\n'
      '2024-06-28 10:05:22 - System maintenance started\n';
}

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sesiones Activas'),
        content: const Text('3 administradores conectados\n2 sesiones web activas\n1 sesión móvil activa'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Backup'),
        content: const Text('¿Deseas crear un backup completo del sistema? Este proceso puede tomar varios minutos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup iniciado en segundo plano'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Crear Backup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
