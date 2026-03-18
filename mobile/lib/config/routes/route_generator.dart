import 'package:flutter/material.dart';
import '../app_routes.dart';
import '../../core/utils/app_logger.dart';
// IMPORTACIONES DE PANTALLAS PRINCIPALES
import '../../features/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/update_password_screen.dart';
import '../../features/client/client_home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/client/booking_history_screen.dart';
import '../../features/debug/screens/system_status_screen.dart';

// IMPORTACIONES DEL FLUJO DE RESERVAS (4 PASOS)
import '../../features/booking/service_options_screen.dart';
import '../../features/booking/provider_selection_screen.dart';
import '../../features/booking/payment_summary_screen.dart';
import '../../features/booking/final_payment_screen.dart';

// IMPORTACIONES DEL FLUJO DE CITAS DIRECTAS (NUEVO)
import '../../features/client/service_details_screen.dart';
import '../../features/client/booking_screen.dart';

// IMPORTACIONES DE CHAT
import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/chat_screen.dart';

// IMPORTACIONES DE PROVIDER Y ADMIN (OPCIONALES)
import '../../features/provider/provider_dashboard.dart';
import '../../features/provider/provider_services_screen.dart';
import '../../features/admin/admin_dashboard.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? AppRoutes.splash;

    AppLogger.i('Navegando a: $routeName', {
      'arguments': settings.arguments?.toString(),
      'type': settings.arguments.runtimeType.toString(),
    });

    switch (routeName) {
      // PANTALLAS PRINCIPALES
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (context) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.updatePassword:
        return MaterialPageRoute(
          builder: (context) => const UpdatePasswordScreen(),
          settings: settings,
        );

      case AppRoutes.clientHome:
        return MaterialPageRoute(
          builder: (context) => const ClientHomeScreen(),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
          settings: settings,
        );

      case AppRoutes.bookingHistory:
        return MaterialPageRoute(
          builder: (context) => const BookingHistoryScreen(),
          settings: settings,
        );

      case AppRoutes.systemStatus:
        return MaterialPageRoute(
          builder: (context) => const SystemStatusScreen(),
          settings: settings,
        );

      // FLUJO DE RESERVAS (4 PASOS) - SISTEMA EXISTENTE
      case AppRoutes.serviceOptions:
        return _buildRoute<ServiceOptionsArguments>(
          settings,
          (args) => ServiceOptionsScreen(arguments: args),
          const ClientHomeScreen(),
        );

      case AppRoutes.providerSelection:
        return _buildRoute<ProviderSelectionArguments>(
          settings,
          (args) => ProviderSelectionScreen(arguments: args),
          const ClientHomeScreen(),
        );

      case AppRoutes.paymentSummary:
        return _buildRoute<PaymentSummaryArguments>(
          settings,
          (args) => PaymentSummaryScreen(arguments: args),
          const ClientHomeScreen(),
        );

      case AppRoutes.finalPayment:
        return _buildRoute<FinalPaymentArguments>(
          settings,
          (args) => FinalPaymentScreen(arguments: args),
          const ClientHomeScreen(),
        );

      // FLUJO DE CITAS DIRECTAS (NUEVO) - MANEJO MEJORADO CON TIPADO FUERTE
      case AppRoutes.serviceDetails:
        return _buildRoute<ServiceDetailsArguments>(
          settings,
          (args) => ServiceDetailsScreen(
            serviceId: args!.serviceId,
            serviceData: args.serviceData,
          ),
          const ClientHomeScreen(),
          allowNullArgs: false,
        );

      case AppRoutes.booking:
        return _buildRoute<BookingArguments>(
          settings,
          (args) => BookingScreen(
            serviceId: args!.serviceId,
            serviceData: args.serviceData,
            providerData: args.providerData,
          ),
          const ClientHomeScreen(),
          allowNullArgs: false,
        );

      // PANTALLAS DE CHAT
      case AppRoutes.chatList:
        return MaterialPageRoute(
          builder: (context) => const ChatListScreen(),
          settings: settings,
        );

      case AppRoutes.chatScreen:
        return _buildRoute<ChatScreenArguments>(
          settings,
          (args) => ChatScreen(
            chatId: args?.chatId,
            otherUserName: args!.requiredOtherUserName,
            otherUserId: args.otherUserId,
            bookingId: args.bookingId,
          ),
          const ChatListScreen(),
          allowNullArgs: false,
        );

      // 👨‍💼 PANTALLAS DE PROVEEDOR
      case AppRoutes.providerDashboard:
        return MaterialPageRoute(
          builder: (context) => const ProviderDashboard(),
          settings: settings,
        );

      case AppRoutes.providerServices:
        return MaterialPageRoute(
          builder: (context) => const ProviderServicesScreen(),
          settings: settings,
        );

      // 👑 PANTALLAS DE ADMIN
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (context) => const AdminDashboard(),
          settings: settings,
        );

      // RUTA POR DEFECTO
      default:
        AppLogger.w('Ruta no encontrada: $routeName, redirigiendo a home');
        return MaterialPageRoute(
          builder: (context) => const ClientHomeScreen(),
          settings: settings,
        );
    }
  }

  /// Helper genérico para contruir rutas de forma segura en tipos
  static Route<dynamic> _buildRoute<T>(
    RouteSettings settings,
    Widget Function(T? args) builder,
    Widget fallback, {
    bool allowNullArgs = true,
  }) {
    final args = settings.arguments;

    if (args is T) {
      return MaterialPageRoute(
        builder: (context) => builder(args),
        settings: settings,
      );
    } else if (allowNullArgs && args == null) {
      return MaterialPageRoute(
        builder: (context) => builder(null),
        settings: settings,
      );
    }

    AppLogger.e(
      'Argumentos inválidos para la ruta ${settings.name}',
      {'expected': T.toString(), 'received': args.runtimeType.toString()},
    );

    return MaterialPageRoute(
      builder: (context) => fallback,
      settings: settings,
    );
  }
}
