import 'package:flutter/material.dart';
import '../app_routes.dart';

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

    debugPrint('Navegando a: $routeName');
    debugPrint('Argumentos: ${settings.arguments}');
    debugPrint('Tipo de argumentos: ${settings.arguments.runtimeType}');

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
        return MaterialPageRoute(
          builder: (context) => ServiceOptionsScreen(
            arguments: settings.arguments as ServiceOptionsArguments?,
          ),
          settings: settings,
        );

      case AppRoutes.providerSelection:
        return MaterialPageRoute(
          builder: (context) => ProviderSelectionScreen(
            arguments: settings.arguments as ProviderSelectionArguments?,
          ),
          settings: settings,
        );

      case AppRoutes.paymentSummary:
        return MaterialPageRoute(
          builder: (context) => PaymentSummaryScreen(
            arguments: settings.arguments as PaymentSummaryArguments?,
          ),
          settings: settings,
        );

      case AppRoutes.finalPayment:
        return MaterialPageRoute(
          builder: (context) => FinalPaymentScreen(
            arguments: settings.arguments as FinalPaymentArguments?,
          ),
          settings: settings,
        );

      // FLUJO DE CITAS DIRECTAS (NUEVO) - MANEJO MEJORADO
      case AppRoutes.serviceDetails:
        final args = settings.arguments;
        debugPrint('Procesando argumentos para service-details: $args');
        debugPrint('Tipo de argumentos: ${args.runtimeType}');

        // Caso 1: ServiceDetailsArguments (ideal)
        if (args is ServiceDetailsArguments) {
          debugPrint('Argumentos tipo ServiceDetailsArguments');
          return MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(
              serviceId: args.serviceId,
              serviceData: args.serviceData,
            ),
            settings: settings,
          );
        }

        // Caso 2: Map<String, dynamic> (fallback) - SIN TRY-CATCH
        if (args is Map<String, dynamic>) {
          debugPrint('Argumentos tipo Map, convirtiendo...');
          final serviceId = args['serviceId']?.toString() ?? '';
          final serviceData = args['serviceData'] as Map<String, dynamic>?;

          debugPrint('ServiceId extraído: $serviceId');
          debugPrint(
              'ServiceData extraído: ${serviceData != null ? 'Sí' : 'No'}');

          if (serviceId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => ServiceDetailsScreen(
                serviceId: serviceId,
                serviceData: serviceData,
              ),
              settings: settings,
            );
          } else {
            debugPrint('ServiceId vacío en argumentos Map');
          }
        }

        // Caso 3: Argumentos inválidos o nulos
        debugPrint('Argumentos inválidos para service-details: $args');
        return MaterialPageRoute(
          builder: (context) => const ClientHomeScreen(),
          settings: settings,
        );

      case AppRoutes.booking:
        try {
          final args = settings.arguments;

          if (args is BookingArguments) {
            return MaterialPageRoute(
              builder: (context) => BookingScreen(
                serviceId: args.serviceId,
                serviceData: args.serviceData,
                providerData: args.providerData,
              ),
              settings: settings,
            );
          } else if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (context) => BookingScreen(
                serviceId: args['serviceId']?.toString() ?? '',
                serviceData: args['serviceData'] as Map<String, dynamic>? ?? {},
                providerData: args['providerData'] as Map<String, dynamic>?,
              ),
              settings: settings,
            );
          }

          debugPrint('Argumentos inválidos para booking: $args');
          return MaterialPageRoute(
            builder: (context) => const ClientHomeScreen(),
            settings: settings,
          );
        } catch (e) {
          debugPrint('Error al procesar argumentos booking: $e');
          return MaterialPageRoute(
            builder: (context) => const ClientHomeScreen(),
            settings: settings,
          );
        }

      // PANTALLAS DE CHAT
      case AppRoutes.chatList:
        return MaterialPageRoute(
          builder: (context) => const ChatListScreen(),
          settings: settings,
        );

      case AppRoutes.chatScreen:
        final args = settings.arguments as ChatScreenArguments?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: args.chatId,
              otherUserName: args.requiredOtherUserName,
              otherUserId: args.otherUserId,
              bookingId: args.bookingId,
            ),
            settings: settings,
          );
        }
        // Fallback or Error if arguments are missing
        debugPrint('Argumentos faltantes para ChatScreen');
        return MaterialPageRoute(
          builder: (context) => const ChatListScreen(),
          settings: settings,
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
        debugPrint('Ruta no encontrada: $routeName, redirigiendo a home');
        return MaterialPageRoute(
          builder: (context) => const ClientHomeScreen(),
          settings: settings,
        );
    }
  }
}
