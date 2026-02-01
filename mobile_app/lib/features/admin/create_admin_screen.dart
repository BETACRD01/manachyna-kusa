import 'package:flutter_application_manachyna_kusa_2_0/core/extensions/supabase_extensions.dart';

// lib/features/admin/create_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/services/admin_service.dart';

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  State<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends State<CreateAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String _selectedLevel = 'admin';
  Map<String, bool> _permissions = {
    'users_management': true,
    'providers_management': true,
    'bookings_management': true,
    'analytics_access': true,
    'settings_management': false,
    'notifications_management': true,
    'payments_management': false,
    'system_management': false,
  };

  final AdminService _adminService = AdminService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Administrador'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildCredentialsSection(),
                    const SizedBox(height: 24),
                    _buildPermissionsSection(),
                    const SizedBox(height: 32),
                    _buildCreateButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Solo los Super Administradores pueden crear nuevos administradores. Asegúrate de verificar la información antes de crear la cuenta.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Información Personal',
      icon: Icons.person,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre Completo *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            if (value.trim().length < 3) {
              return 'El nombre debe tener al menos 3 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_outlined),
            hintText: '+593 9XX XXX XXX',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^\+?[\d\s-()]+$').hasMatch(value)) {
                return 'Formato de teléfono inválido';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _departmentController,
          decoration: const InputDecoration(
            labelText: 'Departamento',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business_outlined),
            hintText: 'ej. Administración, IT, Operaciones',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _positionController,
          decoration: const InputDecoration(
            labelText: 'Cargo',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.work_outline),
            hintText: 'ej. Administrador, Supervisor, Gerente',
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialsSection() {
    return _buildSection(
      title: 'Credenciales de Acceso',
      icon: Icons.security,
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
            hintText: 'admin@manachynakusa.com',
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El email es requerido';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Contraseña *',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          obscureText: !_showPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La contraseña es requerida';
            }
            if (value.length < 8) {
              return 'La contraseña debe tener al menos 8 caracteres';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'La contraseña debe incluir mayúsculas, minúsculas y números';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirmar Contraseña *',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
          obscureText: !_showConfirmPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Confirma la contraseña';
            }
            if (value != _passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedLevel,
          decoration: const InputDecoration(
            labelText: 'Nivel de Administrador',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.admin_panel_settings),
          ),
          items: const [
            DropdownMenuItem(value: 'admin', child: Text('Administrador')),
            DropdownMenuItem(value: 'super_admin', child: Text('Super Administrador')),
            DropdownMenuItem(value: 'moderator', child: Text('Moderador')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedLevel = value!;
              _updatePermissionsForLevel(value);
            });
          },
        ),
      ],
    );
  }

 Widget _buildPermissionsSection() {
  return _buildSection(
    title: 'Permisos y Accesos',
    icon: Icons.verified_user,
    children: [
      const Text(
        'Selecciona los permisos que tendrá este administrador:',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      const SizedBox(height: 16),
      ..._permissions.entries.map((entry) {
        return _buildPermissionTile(
          entry.key,
          _getPermissionLabel(entry.key),
          _getPermissionDescription(entry.key),
          entry.value,
        );
      })
    ],
  );
}


  Widget _buildPermissionTile(String key, String label, String description, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Text(label),
        subtitle: Text(description),
        value: value,
        activeThumbColor: Colors.purple,
        onChanged: (newValue) {
          setState(() {
            _permissions[key] = newValue;
          });
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(icon, color: Colors.purple),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _createAdmin,
        icon: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.admin_panel_settings, color: Colors.white),
        label: Text(
          _isLoading ? 'Creando Administrador...' : 'Crear Administrador',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _updatePermissionsForLevel(String level) {
    switch (level) {
      case 'super_admin':
        _permissions = _permissions.map((key, value) => MapEntry(key, true));
        break;
      case 'admin':
        _permissions = {
          'users_management': true,
          'providers_management': true,
          'bookings_management': true,
          'analytics_access': true,
          'settings_management': false,
          'notifications_management': true,
          'payments_management': false,
          'system_management': false,
        };
        break;
      case 'moderator':
        _permissions = {
          'users_management': true,
          'providers_management': false,
          'bookings_management': true,
          'analytics_access': true,
          'settings_management': false,
          'notifications_management': false,
          'payments_management': false,
          'system_management': false,
        };
        break;
    }
  }

  String _getPermissionLabel(String key) {
    const labels = {
      'users_management': 'Gestión de Usuarios',
      'providers_management': 'Gestión de Proveedores',
      'bookings_management': 'Gestión de Reservas',
      'analytics_access': 'Acceso a Analíticas',
      'settings_management': 'Configuración del Sistema',
      'notifications_management': 'Gestión de Notificaciones',
      'payments_management': 'Gestión de Pagos',
      'system_management': 'Administración del Sistema',
    };
    return labels[key] ?? key;
  }

  String _getPermissionDescription(String key) {
    const descriptions = {
      'users_management': 'Crear, editar y eliminar usuarios clientes',
      'providers_management': 'Aprobar, gestionar y eliminar proveedores',
      'bookings_management': 'Ver y gestionar todas las reservas',
      'analytics_access': 'Acceso a reportes y estadísticas',
      'settings_management': 'Cambiar configuraciones críticas del sistema',
      'notifications_management': 'Enviar y gestionar notificaciones',
      'payments_management': 'Gestionar transacciones y pagos',
      'system_management': 'Acceso completo al sistema (backup, logs, etc.)',
    };
    return descriptions[key] ?? '';
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = Provider.of<AuthProvider>(context, listen: false);
      
      // Verificar que el usuario actual sea super admin
      if (currentUser.userData?['level'] != 'super_admin') {
        throw 'Solo los Super Administradores pueden crear nuevos administradores';
      }

      final adminData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'department': _departmentController.text.trim(),
        'position': _positionController.text.trim(),
        'level': _selectedLevel,
        'permissions': _permissions,
        'createdBy': currentUser.user!.uid,
        'createdAt': DateTime.now(),
      };

      await _adminService.createAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        adminData: adminData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Administrador creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }







  
}
