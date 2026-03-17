import 'package:flutter/material.dart';
import '../admin/screen/users_screen.dart';
import '../admin/screen/pending_requests_screen.dart';
import '../admin/screen/providers_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Constantes para evitar magic numbers
  static const double _headerFontSize = 24.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.people),
              text: 'Usuarios',
            ),
            Tab(
              icon: Icon(Icons.business),
              text: 'Proveedores',
            ),
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Pendientes',
            ),
          ],
        ),
      ),
      drawer: _buildAdminDrawer(context),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UsersScreen(),
          ProvidersScreen(),
          PendingRequestsScreen(),
        ],
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _headerFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Sección actual - Solo informativo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: const Text(
              'GESTIÓN ACTUAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
         const ListTile(
            leading:  Icon(Icons.people, color: Colors.purple),
            title:  Text('Gestión de Usuarios'),
            subtitle:  Text('Vista actual'),
            trailing:  Icon(Icons.check_circle, color: Colors.green),
            onTap: null, // Deshabilitado porque ya estamos aquí
          ),
          const Divider(),
          
          // Otras funciones del admin
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: const Text(
              'OTRAS FUNCIONES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Gestión de Reservas'),
            subtitle: const Text('Ver y administrar reservas'),
            onTap: () {
              Navigator.pop(context);
              // Navegar a pantalla de reservas
              _navigateToReservas(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reportes y Estadísticas'),
            subtitle: const Text('Dashboard de métricas'),
            onTap: () {
              Navigator.pop(context);
              // Navegar a pantalla de reportes
              _navigateToReportes(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            subtitle: const Text('Ajustes del sistema'),
            onTap: () {
              Navigator.pop(context);
              // Navegar a configuración
              _navigateToConfiguracion(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notification_important),
            title: const Text('Notificaciones'),
            subtitle: const Text('Gestionar alertas'),
            onTap: () {
              Navigator.pop(context);
              // Navegar a notificaciones
              _navigateToNotificaciones(context);
            },
          ),
          const Divider(),
          
          // Sección de usuario
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              _navigateToPerfil(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Métodos de navegación para las diferentes pantallas
  void _navigateToReservas(BuildContext context) {
    // Implementar navegación a reservas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegando a Gestión de Reservas...')),
    );
  }

  void _navigateToReportes(BuildContext context) {
    // Implementar navegación a reportes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegando a Reportes...')),
    );
  }

  void _navigateToConfiguracion(BuildContext context) {
    // Implementar navegación a configuración
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegando a Configuración...')),
    );
  }

  void _navigateToNotificaciones(BuildContext context) {
    // Implementar navegación a notificaciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegando a Notificaciones...')),
    );
  }

  void _navigateToPerfil(BuildContext context) {
    // Implementar navegación a perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegando a Mi Perfil...')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implementar lógica de logout
                _performLogout(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    // Implementar lógica de cierre de sesión
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cerrando sesión...')),
    );
  }
}
