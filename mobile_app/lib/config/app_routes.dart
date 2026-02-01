import 'package:flutter/material.dart';
import 'routes/route_arguments.dart';
import 'routes/route_generator.dart';

// RE-EXPORTAR ARGUMENTOS PARA MANTENER COMPATIBILIDAD
export 'routes/route_arguments.dart';

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
  // 🔓 RUTAS PÚBLICAS (sin autenticación)
  // ===============================
  static const Set<String> _publicRoutes = {
    splash,
    serviceOptions,
    serviceDetails,
    paymentSummary,
    login,
    register,
    forgotPassword,
    updatePassword,
  };

  // ===============================
  // 👥 RUTAS POR TIPO DE USUARIO
  // ===============================
  static const Set<String> _clientRoutes = {
    clientHome,
    profile,
    bookingHistory,
    providerSelection,
    finalPayment,
    booking,
  };

  static const Set<String> _providerRoutes = {
    providerDashboard,
    providerServices,
  };

  static const Set<String> _adminRoutes = {
    adminDashboard,
  };

  // ===============================
  // PROXY PARA GENERADOR DE RUTAS
  // ===============================
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return RouteGenerator.generateRoute(settings);
  }

  // ===============================
  // MÉTODOS DE NAVEGACIÓN DEL FLUJO PRINCIPAL (EXISTENTE)
  // ===============================

  /// PASO 1/4: Navegar a Service Options
  static void toServiceOptions(
    BuildContext context, {
    required String serviceId,
    required String serviceName,
    required String serviceCategory,
    required double basePrice,
  }) {
    Navigator.pushNamed(
      context,
      serviceOptions,
      arguments: ServiceOptionsArguments(
        serviceId: serviceId,
        serviceName: serviceName,
        serviceCategory: serviceCategory,
        basePrice: basePrice,
      ),
    );
  }

  /// PASO 2/4: Navegar a Provider Selection
  static void toProviderSelection(
    BuildContext context, {
    required Map<String, dynamic> bookingData,
  }) {
    Navigator.pushNamed(
      context,
      providerSelection,
      arguments: ProviderSelectionArguments(bookingData: bookingData),
    );
  }

  /// PASO 3/4: Navegar a Payment Summary
  static void toPaymentSummary(
    BuildContext context, {
    required Map<String, dynamic> serviceData,
    required List<Map<String, dynamic>> selectedOptions,
    required bool isHeavyWork,
    required double heavyWorkSurcharge,
    required Map<String, dynamic> selectedProvider,
    required Map<String, dynamic> bookingData,
  }) {
    Navigator.pushNamed(
      context,
      paymentSummary,
      arguments: PaymentSummaryArguments(
        serviceData: serviceData,
        selectedOptions: selectedOptions,
        isHeavyWork: isHeavyWork,
        heavyWorkSurcharge: heavyWorkSurcharge,
        selectedProvider: selectedProvider,
        bookingData: bookingData,
      ),
    );
  }

  /// PASO 4/4: Navegar a Final Payment
  static void toFinalPayment(
    BuildContext context, {
    required Map<String, dynamic> finalBookingData,
  }) {
    Navigator.pushNamed(
      context,
      finalPayment,
      arguments: FinalPaymentArguments(finalBookingData: finalBookingData),
    );
  }

  // ===============================
  // MÉTODOS DE NAVEGACIÓN PARA CITAS DIRECTAS (NUEVO)
  // ===============================

  /// Navegar a detalles del servicio (desde búsqueda)
  static void toServiceDetails(
    BuildContext context, {
    required String serviceId,
    Map<String, dynamic>? serviceData,
  }) {
    debugPrint('Navegando a service-details con serviceId: $serviceId');
    Navigator.pushNamed(
      context,
      serviceDetails,
      arguments: ServiceDetailsArguments(
        serviceId: serviceId,
        serviceData: serviceData,
      ),
    );
  }

  /// Navegar a pantalla de reserva directa
  static void toBooking(
    BuildContext context, {
    required String serviceId,
    required Map<String, dynamic> serviceData,
    Map<String, dynamic>? providerData,
  }) {
    Navigator.pushNamed(
      context,
      booking,
      arguments: BookingArguments(
        serviceId: serviceId,
        serviceData: serviceData,
        providerData: providerData,
      ),
    );
  }

  // ===============================
  // MÉTODOS DE NAVEGACIÓN PARA CHAT (ACTUALIZADO A NAMED ROUTES)
  // ===============================
  static void toChatList(BuildContext context) {
    Navigator.pushNamed(context, chatList);
  }

  static void toChatScreen(
    BuildContext context, {
    String? chatId,
    required String otherUserName,
    String? otherUserId,
    String? bookingId,
  }) {
    Navigator.pushNamed(
      context,
      chatScreen,
      arguments: ChatScreenArguments(
        chatId: chatId,
        requiredOtherUserName: otherUserName,
        otherUserId: otherUserId,
        bookingId: bookingId,
      ),
    );
  }

  static void toChatFromBooking(
    BuildContext context, {
    required String clientId,
    required String clientName,
    required String bookingId,
  }) {
    Navigator.pushNamed(
      context,
      chatScreen,
      arguments: ChatScreenArguments(
        requiredOtherUserName: clientName,
        otherUserId: clientId,
        bookingId: bookingId,
      ),
    );
  }

  // ===============================
  // MÉTODOS DE VALIDACIÓN
  // ===============================
  static String getInitialRoute(String? userType) => splash;

  static bool requiresAuth(String route) => !_publicRoutes.contains(route);

  static bool needsLoginToProgress(String currentRoute, String nextRoute) {
    return currentRoute == paymentSummary && nextRoute == providerSelection ||
        currentRoute == serviceDetails && nextRoute == booking ||
        _publicRoutes.contains(currentRoute) &&
            (_clientRoutes.contains(nextRoute) ||
                _providerRoutes.contains(nextRoute) ||
                _adminRoutes.contains(nextRoute));
  }

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
  };

  static String getTitle(String route) =>
      _routeTitles[route] ?? 'Mañachyna Kusa';
}
