// RE-EXPORTAR PARA MANTENER COMPATIBILIDAD EXTERNA
export 'routes/route_arguments.dart';
export 'routes/route_guard.dart';
export 'routes/app_navigator.dart';
export 'routes/route_generator.dart';

class AppRoutes {
  AppRoutes._(); // Constructor privado

  // ===============================
  // RUTAS PRINCIPALES
  // ===============================
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String updatePassword = '/update-password';
  static const String clientHome = '/client-home';
  static const String profile = '/profile';
  static const String bookingHistory = '/booking-history';
  static const String systemStatus = '/system-status';

  // ===============================
  // FLUJO DE RESERVAS (4 PASOS) - SISTEMA EXISTENTE
  // ===============================
  static const String serviceOptions = '/service-options'; // PASO 1/4
  static const String providerSelection = '/provider-selection'; // PASO 2/4
  static const String paymentSummary = '/payment-summary'; // PASO 3/4
  static const String finalPayment = '/final-payment'; // PASO 4/4

  // ===============================
  // FLUJO DE CITAS DIRECTAS (NUEVO) - SISTEMA SIMPLIFICADO
  // ===============================
  static const String serviceDetails =
      '/service-details'; // Ver detalles del servicio
  static const String booking = '/booking'; // Agendar cita directa

  // ===============================
  // RUTAS DE CHAT
  // ===============================
  static const String chatList = '/chat-list';
  static const String chatScreen = '/chat-screen';

  // ===============================
  // 👨‍💼 RUTAS DE PROVEEDOR
  // ===============================
  static const String providerDashboard = '/provider-dashboard';
  static const String providerServices = '/provider-services';

  // ===============================
  // 👑 RUTAS DE ADMIN
  // ===============================
  static const String adminDashboard = '/admin-dashboard';

  // ===============================
  // MÉTODO INICIAL SIMPLIFICADO
  // ===============================
  static String getInitialRoute() => splash;

  // ===============================
  // 📝 TÍTULOS DE PANTALLA
  // ===============================
  static const Map<String, String> _routeTitles = {
    splash: 'Mañachyna Kusa',
    serviceOptions: 'Opciones del Servicio',
    providerSelection: 'Seleccionar Proveedor',
    paymentSummary: 'Resumen del Pedido',
    finalPayment: 'Confirmar Pago',
    serviceDetails: 'Detalles del Servicio',
    booking: 'Agendar Cita',
    login: 'Iniciar Sesión',
    register: 'Crear Cuenta',
    forgotPassword: 'Recuperar Contraseña',
    updatePassword: 'Nueva Contraseña',
    clientHome: 'Panel Cliente',
    profile: 'Mi Perfil',
    bookingHistory: 'Historial de Reservas',
    providerDashboard: 'Panel de Proveedor',
    providerServices: 'Servicios del Proveedor',
    adminDashboard: 'Panel de Administración',
    chatList: 'Mensajes',
    chatScreen: 'Chat',
    systemStatus: 'Estado del Sistema',
  };

  static String getTitle(String route) =>
      _routeTitles[route] ?? 'Mañachyna Kusa';
}
