import 'package:flutter_application_manachyna_kusa_2_0/core/extensions/supabase_extensions.dart';
// lib/features/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'user_management_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'create_admin_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _stats = {
          'totalUsers': 1247,
          'totalProviders': 89,
          'totalBookings': 3456,
          'totalRevenue': 45678.90,
          'activeUsers': 756,
          'pendingApprovals': 12,
          'todayBookings': 23,
          'monthlyGrowth': 12.5,
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadDashboardData();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            
            // Métricas principales
            _buildMainMetrics(),
            const SizedBox(height: 20),
            
            // Gráficos y estadísticas
            _buildChartsSection(),
            const SizedBox(height: 20),
            
            // Actividad reciente
            _buildRecentActivity(),
            const SizedBox(height: 20),
            
            // Acciones rápidas
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final adminName = authProvider.userData?['name'] ?? 
                         authProvider.user?.displayName ?? 
                         'Administrador';
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido, $adminName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Panel de administración de Mañachyna Kusa',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.today, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas Principales',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              title: 'Usuarios Totales',
              value: _stats['totalUsers']?.toString() ?? '0',
              icon: Icons.people,
              color: Colors.blue,
              trend: '+5.2%',
            ),
            _buildMetricCard(
              title: 'Proveedores',
              value: _stats['totalProviders']?.toString() ?? '0',
              icon: Icons.business,
              color: Colors.green,
              trend: '+12.1%',
            ),
            _buildMetricCard(
              title: 'Reservas Totales',
              value: _stats['totalBookings']?.toString() ?? '0',
              icon: Icons.book_online,
              color: Colors.orange,
              trend: '+8.7%',
            ),
            _buildMetricCard(
              title: 'Ingresos',
              value: '\$${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}',
              icon: Icons.attach_money,
              color: Colors.purple,
              trend: '+15.3%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
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
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Gráficos de tendencias',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  'Próximamente disponible',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'action': 'Nuevo usuario registrado', 'time': 'Hace 5 min', 'icon': Icons.person_add},
      {'action': 'Proveedor aprobado', 'time': 'Hace 15 min', 'icon': Icons.check_circle},
      {'action': 'Reserva cancelada', 'time': 'Hace 30 min', 'icon': Icons.cancel},
      {'action': 'Pago procesado', 'time': 'Hace 1 hora', 'icon': Icons.payment},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad Reciente',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: Icon(
                  activity['icon'] as IconData,
                  color: Colors.purple,
                ),
                title: Text(activity['action'] as String),
                subtitle: Text(activity['time'] as String),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                },
              );
            },
          ),
        ),
      ],
    );
  }

 Widget _buildQuickActions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Acciones Rápidas',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2,
        children: [
          _buildActionCard(
            title: 'Gestionar Usuarios',
            icon: Icons.people_outline,
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => const UserManagementScreen(),
            )),
          ),
          _buildActionCard(
            title: 'Ver Analíticas',
            icon: Icons.analytics_outlined,
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => const AnalyticsScreen(),
            )),
          ),
          _buildActionCard(
            title: 'Configuración',
            icon: Icons.settings_outlined,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            )),
          ),
          _buildActionCard(
            title: 'Crear Admin',
            icon: Icons.admin_panel_settings,
            color: Colors.red,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => const CreateAdminScreen(),
            )),
          ),
          _buildActionCard(
            title: 'Reportes',
            icon: Icons.assessment_outlined,
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reportes próximamente')),
              );
            },
          ),
          _buildActionCard(
            title: 'Backup Sistema',
            icon: Icons.backup_outlined,
            color: Colors.teal,
            onTap: () {
              _showBackupDialog();
            },
          ),
        ],
      ),
    ],
  );
}

// Método adicional para el diálogo de backup
void _showBackupDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.backup, color: Colors.teal),
          SizedBox(width: 8),
          Text('Backup del Sistema'),
        ],
      ),
      content: const Text(
        '¿Deseas crear un backup completo del sistema? Este proceso puede tomar varios minutos.',
      ),
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
                backgroundColor: Colors.teal,
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: const Text('Crear Backup', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings, 
                                 size: 30, color: Colors.purple),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Panel Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Mañachyna Kusa',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.people,
                  title: 'Gestión de Usuarios',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const UserManagementScreen(),
                    ));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.analytics,
                  title: 'Analíticas',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const AnalyticsScreen(),
                    ));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Configuración',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ));
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  onTap: () => _handleMenuAction('logout'),
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.grey[700]),
      ),
      onTap: onTap,
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}