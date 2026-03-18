import '../app_routes.dart';

class RouteGuard {
  RouteGuard._(); // Constructor privado

  /// Rutas públicas (sin autenticación)
  static const Set<String> _publicRoutes = {
    AppRoutes.splash,
    AppRoutes.serviceOptions,
    AppRoutes.serviceDetails,
    AppRoutes.paymentSummary,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.updatePassword,
    AppRoutes.systemStatus, // Añadido systemStatus
  };

  /// Rutas de cliente
  static const Set<String> _clientRoutes = {
    AppRoutes.clientHome,
    AppRoutes.profile,
    AppRoutes.bookingHistory,
    AppRoutes.providerSelection,
    AppRoutes.finalPayment,
    AppRoutes.booking,
  };

  /// Rutas de proveedor
  static const Set<String> _providerRoutes = {
    AppRoutes.providerDashboard,
    AppRoutes.providerServices,
  };

  /// Rutas de administrador
  static const Set<String> _adminRoutes = {
    AppRoutes.adminDashboard,
  };

  /// Verifica si una ruta requiere autenticación
  static bool requiresAuth(String route) => !_publicRoutes.contains(route);

  /// Verifica si se necesita iniciar sesión para progresar en un flujo
  static bool needsLoginToProgress(String currentRoute, String nextRoute) {
    return (currentRoute == AppRoutes.paymentSummary && 
            nextRoute == AppRoutes.providerSelection) ||
           (currentRoute == AppRoutes.serviceDetails && 
            nextRoute == AppRoutes.booking) ||
           (_publicRoutes.contains(currentRoute) &&
            (_clientRoutes.contains(nextRoute) ||
             _providerRoutes.contains(nextRoute) ||
             _adminRoutes.contains(nextRoute)));
  }

  /// Verifica si la ruta es específica para un rol de usuario
  static bool isRoleSpecific(String route, String userType) {
    switch (userType.toLowerCase()) {
      case 'provider':
        return _providerRoutes.contains(route);
      case 'admin':
        return _adminRoutes.contains(route);
      case 'client':
        return _clientRoutes.contains(route);
      default:
        return false;
    }
  }
}
