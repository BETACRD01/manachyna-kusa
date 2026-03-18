// ============================================================================
// CLASES DE ARGUMENTOS PARA NAVEGACIÓN
// ============================================================================

/// Argumentos para ServiceOptionsScreen (PASO 1/4) - EXISTENTE
class ServiceOptionsArguments {
  final String serviceId;
  final String serviceName;
  final String serviceCategory;
  final double basePrice;

  const ServiceOptionsArguments({
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategory,
    required this.basePrice,
  });

  @override
  String toString() {
    return 'ServiceOptionsArguments(serviceId: $serviceId, serviceName: $serviceName, serviceCategory: $serviceCategory, basePrice: $basePrice)';
  }
}

/// Argumentos para ProviderSelectionScreen (PASO 2/4) - EXISTENTE
class ProviderSelectionArguments {
  final Map<String, dynamic> bookingData;

  const ProviderSelectionArguments({
    required this.bookingData,
  });

  @override
  String toString() {
    return 'ProviderSelectionArguments(bookingData keys: ${bookingData.keys.toList()})';
  }
}

/// Argumentos para PaymentSummaryScreen (PASO 3/4) - EXISTENTE
class PaymentSummaryArguments {
  final Map<String, dynamic> serviceData;
  final List<Map<String, dynamic>> selectedOptions;
  final bool isHeavyWork;
  final double heavyWorkSurcharge;
  final Map<String, dynamic>? selectedProvider;
  final Map<String, dynamic>? bookingData;

  const PaymentSummaryArguments({
    required this.serviceData,
    required this.selectedOptions,
    required this.isHeavyWork,
    required this.heavyWorkSurcharge,
    this.selectedProvider,
    this.bookingData,
  });

  @override
  String toString() {
    return 'PaymentSummaryArguments(serviceData: ${serviceData['serviceName']}, selectedOptions: ${selectedOptions.length}, provider: ${selectedProvider?['name']})';
  }
}

/// Argumentos para FinalPaymentScreen (PASO 4/4) - EXISTENTE
class FinalPaymentArguments {
  final Map<String, dynamic> finalBookingData;

  const FinalPaymentArguments({
    required this.finalBookingData,
  });

  @override
  String toString() {
    return 'FinalPaymentArguments(finalBookingData keys: ${finalBookingData.keys.toList()})';
  }
}

// ===============================
// NUEVAS CLASES DE ARGUMENTOS PARA CITAS DIRECTAS
// ===============================

/// Argumentos para ServiceDetailsScreen - NUEVO
class ServiceDetailsArguments {
  final String serviceId;
  final Map<String, dynamic>? serviceData;

  const ServiceDetailsArguments({
    required this.serviceId,
    this.serviceData,
  });

  @override
  String toString() {
    return 'ServiceDetailsArguments(serviceId: $serviceId, hasServiceData: ${serviceData != null})';
  }
}

/// Argumentos para BookingScreen - NUEVO
class BookingArguments {
  final String serviceId;
  final Map<String, dynamic> serviceData;
  final Map<String, dynamic>? providerData;

  const BookingArguments({
    required this.serviceId,
    required this.serviceData,
    this.providerData,
  });

  @override
  String toString() {
    return 'BookingArguments(serviceId: $serviceId, serviceTitle: ${serviceData['title']}, hasProviderData: ${providerData != null})';
  }
}

// ===============================
// ARGUMENTOS PARA CHAT
// ===============================

/// Argumentos para ChatScreen
class ChatScreenArguments {
  final String? chatId;
  final String
      requiredOtherUserName; // otherUserName is required in constructor
  final String? otherUserId;
  final String? bookingId;

  const ChatScreenArguments({
    this.chatId,
    required this.requiredOtherUserName,
    this.otherUserId,
    this.bookingId,
  });

  @override
  String toString() {
    return 'ChatScreenArguments(chatId: $chatId, otherUserName: $requiredOtherUserName, bookingId: $bookingId)';
  }
}
