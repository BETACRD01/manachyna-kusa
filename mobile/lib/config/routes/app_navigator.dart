import 'package:flutter/material.dart';
import '../app_routes.dart';
import '../../core/utils/app_logger.dart';

import '../../data/models/service_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/user_model.dart';

class AppNavigator {
  AppNavigator._(); // Private constructor

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
      AppRoutes.serviceOptions,
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
    required BookingModel bookingData,
  }) {
    Navigator.pushNamed(
      context,
      AppRoutes.providerSelection,
      arguments: ProviderSelectionArguments(bookingData: bookingData),
    );
  }

  /// PASO 3/4: Navegar a Payment Summary
  static void toPaymentSummary(
    BuildContext context, {
    required ServiceModel serviceData,
    required List<Map<String, dynamic>> selectedOptions,
    required bool isHeavyWork,
    required double heavyWorkSurcharge,
    UserModel? selectedProvider,
    BookingModel? bookingData,
  }) {
    Navigator.pushNamed(
      context,
      AppRoutes.paymentSummary,
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
    required BookingModel finalBookingData,
  }) {
    Navigator.pushNamed(
      context,
      AppRoutes.finalPayment,
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
    ServiceModel? serviceData,
  }) {
    AppLogger.i('Navegando a service-details', {'serviceId': serviceId});
    Navigator.pushNamed(
      context,
      AppRoutes.serviceDetails,
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
    required ServiceModel serviceData,
    UserModel? providerData,
  }) {
    Navigator.pushNamed(
      context,
      AppRoutes.booking,
      arguments: BookingArguments(
        serviceId: serviceId,
        serviceData: serviceData,
        providerData: providerData,
      ),
    );
  }

  // ===============================
  // MÉTODOS DE NAVEGACIÓN PARA CHAT
  // ===============================
  static void toChatList(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.chatList);
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
      AppRoutes.chatScreen,
      arguments: ChatScreenArguments(
        chatId: chatId,
        requiredOtherUserName: otherUserName,
        otherUserId: otherUserId,
        bookingId: bookingId,
      ),
    );
  }

  /// Navegar a Login
  static void toLogin(
    BuildContext context, {
    bool fromBooking = false,
    String? returnTo,
  }) {
    Navigator.pushNamed(
      context,
      AppRoutes.login,
      arguments: {
        'fromBooking': fromBooking,
        'returnTo': returnTo,
      },
    );
  }
}
